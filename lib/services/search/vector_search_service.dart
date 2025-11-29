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
    
    debugPrint('🔍 DEBUG: Searching for: "$query"');
    debugPrint('📊 DEBUG: Total contacts in DB: ${allContacts.length}');
    
    // 1. Embed the User's Query
    final queryEmbedding = await _aiService.getEmbedding(query);
    
    debugPrint('📐 DEBUG: Query embedding length: ${queryEmbedding.length}');
    
    // Safety check: If embedding fails, fallback to keyword search immediately
    if (queryEmbedding.isEmpty) {
      debugPrint('❌ DEBUG: Query embedding is EMPTY! Falling back to keyword search.');
      return _keywordSearch(allContacts, query, limit);
    }

    // 2. Score Matches (Cosine Similarity)
    List<MapEntry<Contact, double>> scoredContacts = [];
    
    for (var contact in allContacts) {
      if (contact.embedding != null) {
        // Dimension Mismatch Check
        if (contact.embedding!.length != queryEmbedding.length) {
          debugPrint('⚠️ Dimension mismatch for ${contact.name}: Contact=${contact.embedding!.length}, Query=${queryEmbedding.length}. Skipping.');
          continue; 
        }

        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);
        debugPrint('   Similarity for ${contact.name}: $score');

        // RELAXED THRESHOLD: 0.15 allows for typos and loose associations
        if (score > 0.15) { 
          scoredContacts.add(MapEntry(contact, score));
        }
      } else {
         debugPrint('   Skipping ${contact.name} (No embedding)');
      }
    }

    // 3. Fallback Mechanism
    // If vector search found nothing (or dimensions were wrong), try keyword search
    if (scoredContacts.isEmpty) {
       debugPrint('⚠️ No vector matches found. Falling back to keyword search.');
       return _keywordSearch(allContacts, query, limit);
    }

    // 4. Sort & Filter
    scoredContacts.sort((a, b) => b.value.compareTo(a.value));
    return scoredContacts.take(limit).map((e) => e.key).toList();
  }

  // --- Helper: Simple Keyword Search Fallback ---
  List<Contact> _keywordSearch(List<Contact> contacts, String query, int limit) {
    final lowerQuery = query.toLowerCase();
    
    return contacts.where((contact) {
      // Create a giant string of all searchable text
      final text = """
        ${contact.name} 
        ${contact.company ?? ''} 
        ${contact.title ?? ''} 
        ${contact.notes ?? ''} 
        ${contact.addressLabel ?? ''}
      """.toLowerCase();
      
      return text.contains(lowerQuery);
    }).take(limit).toList();
  }

  /// 2. RAG GENERATION (The "Smart" Part)
  Future<String> askYourNetwork(String userQuestion) async {
    // A. RETRIEVE: Find relevant contacts from Isar
    final relevantContacts = await search(userQuestion, limit: 5);
    
    if (relevantContacts.isEmpty) {
      return "I searched your network but couldn't find anyone matching that description. Try adding more contacts or details.";
    }

    // B. AUGMENT: Create the "Context" block
    String contextData = relevantContacts.map((c) => 
      "- ${c.name} (${c.title ?? 'No Title'} at ${c.company ?? 'No Company'}). "
      "Location: ${c.addressLabel ?? 'Unknown'}. "
      "Notes: ${c.notes ?? ''}. "
      "Met on: ${c.metAt.toString().split(' ')[0]}"
    ).join("\n");

    // C. GENERATE: Send prompt to Cactus AI
    final messages = [
      ChatMessage(
        role: "system", 
        content: "You are a helpful networking assistant. Answer the user's question using ONLY the context provided below. If the answer isn't in the context, say you don't know."
      ),
      ChatMessage(
        role: "user", 
        content: "Context from my contacts:\n$contextData\n\nQuestion: $userQuestion"
      )
    ];

    return await _aiService.generateChatResponse(messages);
  }
}