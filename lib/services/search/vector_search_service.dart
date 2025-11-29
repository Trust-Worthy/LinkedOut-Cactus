import 'package:flutter/foundation.dart';
import 'package:cactus/cactus.dart';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';

class VectorSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;

  VectorSearchService(this._repository, this._aiService);

  /// 1. SEMANTIC SEARCH (Retrieval)
  Future<List<Contact>> search(String query, {int limit = 5}) async {
    final allContacts = await _repository.getAllContacts();
    
    // Safety check for empty DB
    if (allContacts.isEmpty) return [];

    // 1. Embed the User's Query
    final queryEmbedding = await _aiService.getEmbedding(query);
    
    if (queryEmbedding.isEmpty) {
      // Fallback to keyword if AI fails
      return _keywordSearch(allContacts, query, limit);
    }

    // 2. Score Matches (Cosine Similarity)
    List<MapEntry<Contact, double>> scoredContacts = [];
    
    for (var contact in allContacts) {
      if (contact.embedding != null) {
        // Dimension Mismatch Check
        if (contact.embedding!.length != queryEmbedding.length) {
          continue; 
        }

        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);

        // RELAXED THRESHOLD: 0.15 allows for typos and loose associations
        if (score > 0.15) { 
          scoredContacts.add(MapEntry(contact, score));
        }
      }
    }

    // 3. Fallback Mechanism
    if (scoredContacts.isEmpty) {
       return _keywordSearch(allContacts, query, limit);
    }

    // 4. Sort & Filter
    scoredContacts.sort((a, b) => b.value.compareTo(a.value));
    return scoredContacts.take(limit).map((e) => e.key).toList();
  }

  List<Contact> _keywordSearch(List<Contact> contacts, String query, int limit) {
    final lowerQuery = query.toLowerCase();
    return contacts.where((contact) {
      final text = "${contact.name} ${contact.company ?? ''} ${contact.title ?? ''} ${contact.addressLabel ?? ''}".toLowerCase();
      return text.contains(lowerQuery);
    }).take(limit).toList();
  }

  /// 2. RAG GENERATION (The "Smart" Part)
  Future<String> askYourNetwork(String userQuestion) async {
    // A. RETRIEVE: Find relevant contacts from Isar
    final relevantContacts = await search(userQuestion, limit: 5);
    
    if (relevantContacts.isEmpty) {
      return "I searched your network but couldn't find anyone matching that description.";
    }

    // B. AUGMENT: Create a dense, information-rich context block
    // We include the ID so the LLM can reference it
    String contextData = relevantContacts.map((c) => 
      "ID:${c.id} | Name:${c.name} | Role:${c.title ?? 'N/A'} @ ${c.company ?? 'N/A'} | Loc:${c.addressLabel ?? 'N/A'} | Notes:${c.notes ?? ''}"
    ).join("\n");

    // C. GENERATE: "Router" Style Prompt
    // We instruct the AI to act as a strict data fetcher, not a conversationalist.
    final messages = [
      ChatMessage(
        role: "system", 
        content: """
You are a precision networking assistant. 
1. Answer the user's question using ONLY the provided Context.
2. Be extremely concise. Do not use filler words.
3. Format every person found as: - [Name](ID) - 1 sentence detail.
4. If the user asks for a list (e.g. 'who in Colorado'), just list them.
        """.trim()
      ),
      ChatMessage(
        role: "user", 
        content: "Context:\n$contextData\n\nQuestion: $userQuestion"
      )
    ];

    return await _aiService.generateChatResponse(messages);
  }
}