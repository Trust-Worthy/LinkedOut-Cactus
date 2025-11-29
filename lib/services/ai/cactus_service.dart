import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CactusService {
  final Logger _logger = Logger();
  
  final CactusLM _visionLM = CactusLM();
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

  // --- 1. Model Management ---

  Future<void> downloadModel({
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      CactusTelemetry.setTelemetryToken('a83c7f7a-43ad-4823-b012-cbeb587ae788');
      onProgress(0.0, "Analyzing available models...");
      
      final models = await _visionLM.getModels(); 
      
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

      if (!textModel.isDownloaded) {
        await _textLM.downloadModel(
          model: textSlug!,
          downloadProcessCallback: (p, s, e) => _handleProgress(p, s, e, onProgress, 0.0, 0.5),
        );
      }

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
      final range = endRange - startRange;
      final actualProgress = startRange + ((p ?? 0.0) * range);
      callback(actualProgress, s);
    }
  }

  Future<void> initialize() async {
    if (isInitialized) return;
    try {
      if (visionSlug == null || textSlug == null) {
        final models = await _visionLM.getModels();
        visionSlug = models.firstWhere((m) => m.supportsVision, orElse: () => models.first).slug;
        textSlug = models.firstWhere((m) => !m.supportsVision && m.slug != visionSlug, orElse: () => models.last).slug;
      }

      await _textLM.initializeModel(params: CactusInitParams(model: textSlug!));
      await _visionLM.initializeModel(params: CactusInitParams(model: visionSlug!));
      isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  // --- 2. Vision Tasks ---
  Future<String> scanBusinessCard(String imagePath) async {
    if (!isInitialized) await initialize();
    
    final result = await _visionLM.generateCompletion(
      messages: [ChatMessage(role: "user", content: "Read this card.", images: [imagePath])],
      params: CactusCompletionParams(maxTokens: 500),
    );
    return result.success ? result.response : throw Exception("Vision failed");
  }

  // --- 3. Parsing ---
  Future<Map<String, String?>> parseCardText(String rawText) async {
    if (!isInitialized) await initialize();

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

  // --- 4. Embeddings ---
  Future<List<double>> getEmbedding(String text) async {
    if (!isInitialized) await initialize();
    try {
      final result = await _textLM.generateEmbedding(text: text);
      if (result.success) return result.embeddings;
      throw Exception("Embedding failed");
    } catch (e) {
      return [];
    }
  }

  // --- 5. RAG Chat ---
  Future<String> generateChatResponse(List<ChatMessage> messages) async {
    if (!isInitialized) await initialize();
    final result = await _textLM.generateCompletion(
      messages: messages,
      params: CactusCompletionParams(maxTokens: 500, temperature: 0.7),
    );
    return result.success ? result.response : "I lost my train of thought.";
  }

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
      // 1. Remove <think> tags (Reasoning models)
      String cleaned = llmOutput.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
      
      // 2. Remove Markdown
      cleaned = cleaned.trim()
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '');
      
      // 3. Find JSON boundaries
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
        // Only map notes if they aren't just "Here is the JSON"
        'notes': parsed['notes']?.toString(), 
      };
    } catch (e) {
      // Return empty map on failure so Regex fallback can take over entirely
      return {};
    }
  }
  
  void dispose() {
    _visionLM.unload();
    _textLM.unload();
  }
}