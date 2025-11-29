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

  bool isInitialized = false;
  String? visionSlug;
  String? textSlug;

  bool isModelReady() {
    return _visionLM.isLoaded() && _textLM.isLoaded();
  }

  // --- 1. Intelligent Model Selection & Download ---

  Future<void> downloadModel({
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      CactusTelemetry.setTelemetryToken('a83c7f7a-43ad-4823-b012-cbeb587ae788');
      onProgress(0.0, "Analyzing available models...");
      
      final models = await _visionLM.getModels(); // List is same for both
      
      // A. Select Best Vision Model (Prioritize Liquid/LFM)
      final visionModel = models.firstWhere(
        (m) => m.slug.contains('lfm') && m.supportsVision,
        orElse: () => models.firstWhere((m) => m.supportsVision),
      );
      visionSlug = visionModel.slug;

      // B. Select Best Text Model (Prioritize Qwen or Gemma for reasoning)
      // We explicitly exclude the vision model to ensure we get a dedicated text expert
      final textModel = models.firstWhere(
        (m) => (m.slug.contains('qwen') || m.slug.contains('gemma')) && !m.supportsVision,
        orElse: () => models.firstWhere((m) => !m.supportsVision && m.slug != visionSlug),
      );
      textSlug = textModel.slug;

      _logger.i("👁️ Vision Model: $visionSlug");
      _logger.i("🧠 Text Model:   $textSlug");

      // --- Download Phase 1: The Brain (Text) ---
      if (!textModel.isDownloaded) {
        await _textLM.downloadModel(
          model: textSlug!,
          downloadProcessCallback: (p, s, e) => _handleProgress(p, s, e, onProgress, 0.0, 0.5),
        );
      }

      // --- Download Phase 2: The Eyes (Vision) ---
      if (!visionModel.isDownloaded) {
        await _visionLM.downloadModel(
          model: visionSlug!,
          downloadProcessCallback: (p, s, e) => _handleProgress(p, s, e, onProgress, 0.5, 1.0),
        );
      }

      onProgress(1.0, "Initializing AI Systems...");
      await initialize();
      
    } catch (e) {
      _logger.e("Download Exception: $e");
      rethrow;
    }
  }

  void _handleProgress(double? p, String s, bool e, Function callback, double startRange, double endRange) {
    if (e) {
      _logger.e("Download Error: $s");
    } else {
      // Map 0.0-1.0 to startRange-endRange
      final range = endRange - startRange;
      final actualProgress = startRange + ((p ?? 0.0) * range);
      callback(actualProgress, s);
    }
  }

  Future<void> initialize() async {
    if (isInitialized) return;
    try {
      // --- FIX: Auto-Select Models if App Restarted ---
      // If we skipped onboarding/download, these will be null. We must re-select them.
      if (visionSlug == null || textSlug == null) {
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
        
        _logger.i("Restored: Vision=$visionSlug, Text=$textSlug");
      }

      _logger.i("Initializing Text Engine ($textSlug)...");
      await _textLM.initializeModel(params: CactusInitParams(model: textSlug!));
      
      _logger.i("Initializing Vision Engine ($visionSlug)...");
      await _visionLM.initializeModel(params: CactusInitParams(model: visionSlug!));
      
      isInitialized = true;
      _logger.i("✅ Both AI Systems Ready");
    } catch (e) {
      _logger.e("Init Error: $e");
      rethrow;
    }
  }

  // --- 2. Vision Tasks (Use Vision LM) ---

  Future<String> scanBusinessCard(String imagePath) async {
    if (!isInitialized) await initialize();
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
    if (!isInitialized) await initialize();
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
    if (!isInitialized) await initialize();

    try {
      // Text models produce MUCH better embeddings than vision models
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
    if (!isInitialized) await initialize();
    _logger.i("Thinking with $textSlug...");

    final result = await _textLM.generateCompletion(
      messages: messages,
      params: CactusCompletionParams(maxTokens: 500, temperature: 0.7),
    );

    return result.success ? result.response : "I lost my train of thought.";
  }

  // --- 6. Chat Streaming (Use Text LM) ---
  
  Stream<String> streamChat(List<ChatMessage> history) async* {
    if (!isInitialized) await initialize();

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