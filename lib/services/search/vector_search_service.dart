import 'package:flutter/foundation.dart';
import 'package:cactus/cactus.dart';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';

class RAGResponse {
  final String narrative;
  final List<Contact> sources;

  RAGResponse({required this.narrative, required this.sources});
}

class VectorSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;

  VectorSearchService(this._repository, this._aiService);

  /// 1. PURE VECTOR SEARCH (Retrieval)
  Future<List<Contact>> search(String query, {double threshold = 0.20, int limit = 10}) async {
    final allContacts = await _repository.getAllContacts();
    if (allContacts.isEmpty) return [];

    final queryEmbedding = await _aiService.getEmbedding(query);
    if (queryEmbedding.isEmpty) return [];

    List<MapEntry<Contact, double>> scoredContacts = [];
    for (var contact in allContacts) {
      if (contact.embedding != null) {
        if (contact.embedding!.length != queryEmbedding.length) continue;

        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);
        if (score > threshold) { 
          scoredContacts.add(MapEntry(contact, score));
        }
      }
    }

    scoredContacts.sort((a, b) => b.value.compareTo(a.value));
    return scoredContacts.take(limit).map((e) => e.key).toList();
  }

  /// 2. RAG GENERATION (Retrieval + Generation)
  Future<RAGResponse> queryWithRAG(String userQuestion) async {
    List<Contact> relevantContacts;
    String systemPrompt;

    // --- A. STRATEGY: TIMELINE NARRATIVE ---
    if (userQuestion.toLowerCase().contains("timeline") || 
        userQuestion.toLowerCase().contains("journey") || 
        userQuestion.toLowerCase().contains("history")) {
      
      debugPrint("🕰️ Triggering Timeline Narrative...");
      // Get all contacts, Sort Chronologically (Oldest -> Newest)
      relevantContacts = await _repository.getAllContacts();
      relevantContacts.sort((a, b) => a.metAt.compareTo(b.metAt));
      
      // Limit to last 15 interactions to fit in context window
      if (relevantContacts.length > 15) {
        relevantContacts = relevantContacts.sublist(relevantContacts.length - 15);
      }
      
      systemPrompt = "You are a biographer. Construct a chronological narrative of the user's networking journey based on the dates provided. Highlight key locations and role transitions.";
    
    } else {
    // --- B. STRATEGY: SEMANTIC LOOKUP ---
      debugPrint("🔍 Triggering Semantic Search...");
      relevantContacts = await search(userQuestion, threshold: 0.20, limit: 6);
      
      if (relevantContacts.isEmpty) {
        return RAGResponse(
          narrative: "I couldn't find anyone in your network matching that description.",
          sources: []
        );
      }
      systemPrompt = "You are a helpful networking assistant. Answer the user's question using ONLY the context provided below. Be conversational but concise.";
    }

    // C. AUGMENT (Build Context)
    String contextBlock = relevantContacts.map((c) => 
      """
      - Name: ${c.name}
      - Role: ${c.title ?? 'N/A'} at ${c.company ?? 'N/A'}
      - Location: ${c.addressLabel ?? 'Unknown'}
      - Met Date: ${c.metAt.toString().substring(0, 10)}
      - Notes: ${c.notes ?? ''}
      """
    ).join("\n");

    // D. GENERATE (Ask AI)
    final messages = [
      ChatMessage(role: "system", content: systemPrompt),
      ChatMessage(
        role: "user", 
        content: "Context from my network:\n$contextBlock\n\nQuestion/Task: $userQuestion"
      )
    ];

    final narrative = await _aiService.generateChatResponse(messages);

    return RAGResponse(narrative: narrative, sources: relevantContacts);
  }
}