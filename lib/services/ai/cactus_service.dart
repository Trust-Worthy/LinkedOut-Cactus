import 'dart:io';
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CactusService {
  final Logger _logger = Logger();
  final CactusLM _lm = CactusLM();
  
  // Singleton Pattern
  static final CactusService _instance = CactusService._internal();
  factory CactusService() => _instance;
  CactusService._internal();
  static CactusService get instance => _instance;

  // State
  bool isInitialized = false;
  String? currentModelSlug;

  /// Check if model is already loaded in memory
  bool isModelReady() {
    return _lm.isLoaded();
  }

  // --- 1. Model Management (Download & Init) ---

  /// Downloads the best available Vision model.
  /// Pass a callback so the UI (OnboardingScreen) can update the progress bar.
  Future<void> downloadModel({
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      // 0. Setup Telemetry (Required for some SDK versions)
      CactusTelemetry.setTelemetryToken('a83c7f7a-43ad-4823-b012-cbeb587ae788');

      onProgress(0.0, "Fetching model list...");
      
      // 1. Get available models
      final models = await _lm.getModels();
      
      // 2. Select a model that supports VISION (Critical for LinkedOut)
      // If no vision model found, fallback to the first available (Text only)
      final selectedModel = models.firstWhere(
        (m) => m.supportsVision, 
        orElse: () => models.first
      );
      
      currentModelSlug = selectedModel.slug;
      _logger.i("Selected model: $currentModelSlug (Vision: ${selectedModel.supportsVision})");

      // 3. Check if already downloaded
      if (selectedModel.isDownloaded) {
        onProgress(1.0, "Model already downloaded.");
      } else {
        // 4. Download
        await _lm.downloadModel(
          model: currentModelSlug!,
          downloadProcessCallback: (progress, status, isError) {
             if (isError) {
               onProgress(0.0, "Error: $status");
               _logger.e("Download failed: $status");
             } else {
               onProgress(progress ?? 0.0, status);
             }
          },
        );
      }

      // 5. Auto-initialize after download
      onProgress(1.0, "Initializing AI Engine...");
      await initialize();
      
    } catch (e) {
      _logger.e("Download Exception: $e");
      rethrow;
    }
  }

  /// Loads the model into memory so it's ready for inference
  Future<void> initialize() async {
    if (isInitialized) return;
    
    try {
      _logger.i("Initializing model...");
      
      // If we don't have a slug yet, try to find one or let Cactus use default
      if (currentModelSlug == null) {
         final models = await _lm.getModels();
         final visionModel = models.firstWhere((m) => m.supportsVision, orElse: () => models.first);
         currentModelSlug = visionModel.slug;
      }

      await _lm.initializeModel(
        params: CactusInitParams(model: currentModelSlug!)
      );
      
      isInitialized = true;
      _logger.i("Cactus SDK Initialized & Ready");
    } catch (e) {
      _logger.e("Initialization Error: $e");
      rethrow;
    }
  }

  // --- 2. Vision (Business Card OCR) ---

  /// Takes an image path, returns the raw text description/extraction
  Future<String> scanBusinessCard(String imagePath) async {
    if (!isInitialized) await initialize();

    _logger.i("Scanning business card: $imagePath");
    
    try {
      final result = await _lm.generateCompletion(
        messages: [
          ChatMessage(
            role: "system",
            content: "You are an expert OCR assistant. Your job is to extract text from business cards accurately.",
          ),
          ChatMessage(
            role: "user",
            content: "Extract all text from this business card image. Return ONLY the text found.",
            images: [imagePath],
          )
        ],
        params: CactusCompletionParams(maxTokens: 500),
      );

      if (result.success) {
        return result.response;
      } else {
        throw Exception("Vision generation failed");
      }
    } catch (e) {
      _logger.e("Vision Error: $e");
      rethrow;
    }
  }

  // --- 3. LLM (Parsing to JSON) ---

  /// Takes raw text, returns a Map of structured data
  Future<Map<String, String?>> parseCardText(String rawText) async {
    _logger.i("Parsing extracted text...");
    
    const prompt = """
    Parse the following text from a business card into a JSON object with these keys: 
    name, company, title, email, phone, notes. 
    If a field is not found, return null. 
    Do not add markdown formatting. Return only JSON.
    
    Text:
    """;

    final result = await _lm.generateCompletion(
      messages: [
        ChatMessage(role: "user", content: "$prompt$rawText")
      ],
      params: CactusCompletionParams(temperature: 0.1), // Low temp for precision
    );

    if (result.success) {
      return _mockParseJson(result.response); 
    }
    throw Exception("Parsing failed");
  }

  // --- 4. Embeddings (Vector Search) ---

  Future<List<double>> getEmbedding(String text) async {
    try {
      final result = await _lm.generateEmbedding(text: text);
      if (result.success) {
        return result.embeddings;
      }
      throw Exception("Embedding failed");
    } catch (e) {
      _logger.e("Embedding Error: $e");
      return [];
    }
  }

  // --- 5. Chat Streaming ---
  
  Stream<String> streamChat(List<ChatMessage> history) async* {
    if (!isInitialized) await initialize();

    final result = await _lm.generateCompletionStream(
      messages: history,
      params: CactusCompletionParams(maxTokens: 500),
    );

    await for (final chunk in result.stream) {
      yield chunk;
    }
  }
  
  // --- Helpers & Cleanup ---

  // Hacky helper to avoid writing a full JSON parser in the prompt response for now
  Map<String, String?> _mockParseJson(String llmOutput) {
     // TODO: Implement actual JSON cleaning (remove ```json) and decoding
     // For the hackathon MVP, we return a mock map to prevent UI crashes if the LLM output is messy
     // In the next step, we can add `dart:convert` and `jsonDecode` here.
     return {
       "name": "Parsed Name", 
       "company": "Parsed Company",
       "email": "email@example.com",
       "title": "Developer"
     };
  }

  void dispose() {
    _lm.unload();
  }
}