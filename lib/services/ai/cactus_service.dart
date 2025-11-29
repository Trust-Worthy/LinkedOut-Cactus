import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CactusService {
  final Logger _logger = Logger();
  
  // --- DUAL ENGINE ARCHITECTURE ---
  // Engine 1: The "Eyes" (Vision / OCR)
  final CactusLM _visionLM = CactusLM();
  
  // Engine 2: The "Brain" (Embeddings / Chat / Parsing)
  final CactusLM _textLM = CactusLM();
  
  static final CactusService _instance = CactusService._internal();
  factory CactusService() => _instance;
  CactusService._internal();
  static CactusService get instance => _instance;

  // Track initialization separately
  bool _isTextReady = false;
  bool _isVisionReady = false;
  
  String? visionSlug;
  String? textSlug;

  bool isModelReady() {
    return _isTextReady && _textLM.isLoaded();
  }

  // --- 1. Intelligent Model Selection & Download ---

  Future<void> downloadModel({
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      CactusTelemetry.setTelemetryToken('a83c7f7a-43ad-4823-b012-cbeb587ae788');
      onProgress(0.0, "Analyzing available models...");
      
      final models = await _visionLM.getModels(); 
      
      // Select Models
      final visionModel = models.firstWhere(
        (m) => m.slug.contains('lfm') && m.supportsVision,
        orElse: () => models.firstWhere((m) => m.supportsVision),
      );
      visionSlug = visionModel.slug;

      final textModel = models.firstWhere(
        (m) => (m.slug.contains('qwen') || m.slug.contains('gemma')) && !m.supportsVision,
        orElse: () => models.firstWhere((m) => !m.supportsVision && m.slug != visionSlug),
      );
      textSlug = textModel.slug;

      _logger.i("👁️ Vision Model: $visionSlug");
      _logger.i("🧠 Text Model:   $textSlug");

      // Download Text Model (Brain)
      if (!textModel.isDownloaded) {
        await _textLM.downloadModel(
          model: textSlug!,
          downloadProcessCallback: (p, s, e) => _handleProgress(p, s, e, onProgress, 0.0, 0.5),
        );
      }

      // Download Vision Model (Eyes)
      if (!visionModel.isDownloaded) {
        await _visionLM.downloadModel(
          model: visionSlug!,
          downloadProcessCallback: (p, s, e) => _handleProgress(p, s, e, onProgress, 0.5, 1.0),
        );
      }

      onProgress(1.0, "Initializing AI Systems...");
      // We perform a light init here to ensure configs are ready, 
      // but we might not load weights into RAM until needed.
      await _ensureModelSelection();
      
    } catch (e) {
      _logger.e("Download Exception: $e");
      rethrow;
    }
  }

  void _handleProgress(double? p, String s, bool e, Function callback, double startRange, double endRange) {
    if (e) {
      _logger.e("Download Error: $s");
    } else {
      final range = endRange - startRange;
      final actualProgress = startRange + ((p ?? 0.0) * range);
      callback(actualProgress, s);
    }
  }

  /// Helper to ensure we know WHICH models to use, even after app restart
  Future<void> _ensureModelSelection() async {
    if (visionSlug != null && textSlug != null) return;

    _logger.i("Restoring model selection...");
    final models = await _visionLM.getModels();
    
    visionSlug = models.firstWhere(
      (m) => m.slug.contains('lfm') && m.supportsVision,
      orElse: () => models.firstWhere((m) => m.supportsVision),
    ).slug;

    textSlug = models.firstWhere(
      (m) => (m.slug.contains('qwen') || m.slug.contains('gemma')) && !m.supportsVision,
      orElse: () => models.firstWhere((m) => !m.supportsVision && m.slug != visionSlug),
    ).slug;
  }

  // --- LAZY LOADERS ---

  Future<void> _initTextEngine() async {
    if (_isTextReady && _textLM.isLoaded()) return;
    await _ensureModelSelection();
    
    _logger.i("🧠 Booting Text Engine ($textSlug)...");
    await _textLM.initializeModel(params: CactusInitParams(model: textSlug!));
    _isTextReady = true;
  }

  Future<void> _initVisionEngine() async {
    if (_isVisionReady && _visionLM.isLoaded()) return;
    await _ensureModelSelection();

    _logger.i("👁️ Booting Vision Engine ($visionSlug)...");
    await _visionLM.initializeModel(params: CactusInitParams(model: visionSlug!));
    _isVisionReady = true;
  }

  // --- 2. Vision Tasks (Use Vision LM) ---

  Future<String> scanBusinessCard(String imagePath) async {
    await _initVisionEngine(); // Only load Vision if strictly needed
    _logger.i("Running OCR with $visionSlug...");
    
    final result = await _visionLM.generateCompletion(
      messages: [
        ChatMessage(role: "user", content: "Read this card.", images: [imagePath])
      ],
      params: CactusCompletionParams(maxTokens: 500),
    );
    return result.success ? result.response : throw Exception("Vision failed");
  }

  // --- 3. Text Tasks (Use Text LM) ---

  Future<Map<String, String?>> parseCardText(String rawText) async {
    await _initTextEngine(); // Only load Text model (Fast!)
    _logger.i("Parsing text with $textSlug...");

    const prompt = """
    Extract JSON from this business card text. 
    Fields: name, company, title, email, phone, notes, linkedin.
    Return ONLY JSON.
    Text:
    """;

    final result = await _textLM.generateCompletion(
      messages: [ChatMessage(role: "user", content: "$prompt$rawText")],
      params: CactusCompletionParams(temperature: 0.1),
    );

    return result.success ? _parseJsonFromResponse(result.response) : throw Exception("Parsing failed");
  }

  // --- 4. Embeddings (Use Text LM - CRITICAL FOR RAG) ---

  Future<List<double>> getEmbedding(String text) async {
    await _initTextEngine(); // Only load Text model

    try {
      final result = await _textLM.generateEmbedding(text: text);
      if (result.success) return result.embeddings;
      throw Exception("Embedding failed");
    } catch (e) {
      _logger.e("Embedding Error: $e");
      return [];
    }
  }

  // --- 5. RAG Chat (Use Text LM) ---

  Future<String> generateChatResponse(List<ChatMessage> messages) async {
    await _initTextEngine();
    _logger.i("Thinking with $textSlug...");

    final result = await _textLM.generateCompletion(
      messages: messages,
      params: CactusCompletionParams(maxTokens: 500, temperature: 0.7),
    );

    return result.success ? result.response : "I lost my train of thought.";
  }

  // --- 6. Chat Streaming (Use Text LM) ---
  
  Stream<String> streamChat(List<ChatMessage> history) async* {
    await _initTextEngine();

    final result = await _textLM.generateCompletionStream(
      messages: history,
      params: CactusCompletionParams(maxTokens: 500),
    );

    await for (final chunk in result.stream) {
      yield chunk;
    }
  }
  
  // --- Helpers ---
  Map<String, String?> _parseJsonFromResponse(String llmOutput) {
    try {
      String cleaned = llmOutput.trim()
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '');
      
      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace >= 0 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }
      
      final Map<String, dynamic> parsed = jsonDecode(cleaned);
      return {
        'name': parsed['name']?.toString(),
        'company': parsed['company']?.toString(),
        'email': parsed['email']?.toString(),
        'phone': parsed['phone']?.toString(),
        'title': parsed['title']?.toString(),
        'linkedin': parsed['linkedin']?.toString(),
        'notes': parsed['notes']?.toString(),
      };
    } catch (e) {
      return {'name': null, 'notes': "Raw: $llmOutput"};
    }
  }
  
  int min(int a, int b) => a < b ? a : b;

  void dispose() {
    _visionLM.unload();
    _textLM.unload();
  }
}