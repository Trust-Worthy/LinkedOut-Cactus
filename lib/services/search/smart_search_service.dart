import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cactus/cactus.dart';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';

class SmartSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;

  SmartSearchService(this._repository, this._aiService);

  Future<List<Contact>> search(String userQuery) async {
    // 1. Analyze Intent (The "Router" Agent)
    // We ask the LLM to extract structured data instead of writing a paragraph.
    final intent = await _parseIntent(userQuery);
    
    debugPrint("🎯 Search Intent: $intent");

    // 2. Fetch All Contacts
    // For on-device DBs (< 10k items), fetching all is faster than complex SQL queries
    var contacts = await _repository.getAllContacts();

    // 3. Apply Hard Filters (Fast & Accurate)
    
    // Location Filter
    if (intent['location'] != null && intent['location'].isNotEmpty) {
      final loc = intent['location'].toLowerCase();
      contacts = contacts.where((c) => 
        (c.addressLabel ?? '').toLowerCase().contains(loc)
      ).toList();
    }

    // Company Filter
    if (intent['company'] != null && intent['company'].isNotEmpty) {
      final comp = intent['company'].toLowerCase();
      contacts = contacts.where((c) => 
        (c.company ?? '').toLowerCase().contains(comp)
      ).toList();
    }

    // Name Filter
    if (intent['person'] != null && intent['person'].isNotEmpty) {
      final name = intent['person'].toLowerCase();
      contacts = contacts.where((c) => 
        c.name.toLowerCase().contains(name)
      ).toList();
    }

    // 4. Semantic Ranking (The "Vibe" Check)
    // If we have a 'topic' or 'skill', or if filters didn't narrow it down enough,
    // we use vector search on the remaining results.
    if (intent['topic'] != null || contacts.length > 5) {
      final topic = intent['topic'] ?? userQuery; // Fallback to full query
      contacts = await _rankBySimilarity(contacts, topic);
    }

    return contacts;
  }

  // --- Helpers ---

  Future<Map<String, dynamic>> _parseIntent(String query) async {
    const systemPrompt = """
    Analyze the search query. Extract entities into JSON:
    - location: City/State/Country names
    - company: Organization names
    - person: Specific names
    - topic: Skills, jobs, topics (e.g. "VCs", "Python", "investing")
    
    Return ONLY JSON. Example: {"location": "Denver", "topic": "software"}
    If a field is missing, use null.
    """;

    try {
      final response = await _aiService.generateChatResponse([
        ChatMessage(role: "system", content: systemPrompt),
        ChatMessage(role: "user", content: query),
      ]);

      return _cleanAndParseJson(response);
    } catch (e) {
      debugPrint("Intent parsing failed: $e");
      return {}; // Fallback to empty intent (will just return all contacts or vector search)
    }
  }

  Future<List<Contact>> _rankBySimilarity(List<Contact> contacts, String query) async {
    final queryEmbedding = await _aiService.getEmbedding(query);
    if (queryEmbedding.isEmpty) return contacts;

    final scored = <MapEntry<Contact, double>>[];

    for (var c in contacts) {
      if (c.embedding != null) {
        // Dimension check
        if (c.embedding!.length == queryEmbedding.length) {
          final score = VectorUtils.cosineSimilarity(queryEmbedding, c.embedding!);
          if (score > 0.15) { // Threshold
            scored.add(MapEntry(c, score));
          }
        }
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value)); // High score first
    return scored.map((e) => e.key).toList();
  }

  Map<String, dynamic> _cleanAndParseJson(String text) {
    try {
      String cleaned = text.trim()
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '');
      
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start >= 0 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }
      return jsonDecode(cleaned);
    } catch (e) {
      return {};
    }
  }
}