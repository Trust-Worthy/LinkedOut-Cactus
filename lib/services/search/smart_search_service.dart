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
    final intent = await _parseIntent(userQuery);
    
    debugPrint("🎯 Search Intent Raw: $intent");

    // Gatekeeper: If AI thinks this isn't a search, stop immediately.
    // This prevents returning random cards for queries like "Hello" or "Write a poem".
    if (intent['is_search'] == false) {
      return [];
    }

    // 2. Fetch All Contacts
    var contacts = await _repository.getAllContacts();

    // 3. Apply Hard Filters (Fast & Accurate)
    // We use _safeString to prevent crashes if LLM returns a List instead of String
    
    final locationIntent = _safeString(intent['location']);
    final companyIntent = _safeString(intent['company']);
    final personIntent = _safeString(intent['person']);
    final topicIntent = _safeString(intent['topic']);

    // Location Filter
    if (locationIntent != null) {
      final loc = locationIntent.toLowerCase();
      contacts = contacts.where((c) => 
        (c.addressLabel ?? '').toLowerCase().contains(loc)
      ).toList();
    }

    // Company Filter
    if (companyIntent != null) {
      final comp = companyIntent.toLowerCase();
      contacts = contacts.where((c) => 
        (c.company ?? '').toLowerCase().contains(comp)
      ).toList();
    }

    // Name Filter
    if (personIntent != null) {
      final name = personIntent.toLowerCase();
      contacts = contacts.where((c) => 
        c.name.toLowerCase().contains(name)
      ).toList();
    }

    // 4. Semantic Ranking (The "Vibe" Check)
    if (topicIntent != null || contacts.length > 5) {
      // If topicIntent was empty/null, fallback to userQuery.
      // Ensure we don't pass an empty string if userQuery was somehow empty (unlikely but safe).
      final topic = (topicIntent ?? userQuery).trim();
      if (topic.isNotEmpty) {
        contacts = await _rankBySimilarity(contacts, topic);
      }
    }

    return contacts;
  }

  // --- Helpers ---

  // FIX: Robustly handle dynamic types AND empty strings
  String? _safeString(dynamic value) {
    if (value == null) return null;
    
    String result;
    if (value is String) {
      result = value;
    } else if (value is List) {
      result = value.join(' '); // Convert ["VC", "Tech"] -> "VC Tech"
    } else {
      result = value.toString(); // Fallback for numbers/bools
    }
    
    // Critical Fix: Trim whitespace and return null if empty
    // This prevents sending " " or "" to the embedding model
    result = result.trim();
    return result.isEmpty ? null : result;
  }

  Future<Map<String, dynamic>> _parseIntent(String query) async {
    const systemPrompt = """
    Analyze the input. Determine if the user is searching for specific contacts, people, companies, or locations in their network.
    
    Return JSON with these fields:
    - is_search: (boolean) true if looking for contact info, false if just chitchat or unrelated.
    - location: City/State/Country names
    - company: Organization names
    - person: Specific names
    - topic: Skills, jobs, topics (e.g. "VCs", "Python", "investing")
    
    Example: {"is_search": true, "location": "Denver", "topic": "software"}
    Example: {"is_search": false}
    """;

    try {
      final response = await _aiService.generateChatResponse([
        ChatMessage(role: "system", content: systemPrompt),
        ChatMessage(role: "user", content: query),
      ]);

      return _cleanAndParseJson(response);
    } catch (e) {
      debugPrint("Intent parsing failed: $e");
      return {}; 
    }
  }

  Future<List<Contact>> _rankBySimilarity(List<Contact> contacts, String query) async {
    // Double check to ensure no empty queries hit the embedding model
    if (query.trim().isEmpty) return contacts;

    final queryEmbedding = await _aiService.getEmbedding(query);
    if (queryEmbedding.isEmpty) return contacts;

    final scored = <MapEntry<Contact, double>>[];

    for (var c in contacts) {
      if (c.embedding != null) {
        if (c.embedding!.length == queryEmbedding.length) {
          final score = VectorUtils.cosineSimilarity(queryEmbedding, c.embedding!);
          if (score > 0.15) { 
            scored.add(MapEntry(c, score));
          }
        }
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value)); 
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