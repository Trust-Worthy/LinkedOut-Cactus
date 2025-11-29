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

    // 2. Fetch All Contacts
    var contacts = await _repository.getAllContacts();

    // 3. Apply Hard Filters (Fast & Accurate)
    // We use _safeString to prevent crashes if LLM returns a List instead of String
    
    final locationIntent = _safeString(intent['location']);
    final companyIntent = _safeString(intent['company']);
    final personIntent = _safeString(intent['person']);
    final topicIntent = _safeString(intent['topic']);

    // Location Filter
    if (locationIntent != null && locationIntent.isNotEmpty) {
      final loc = locationIntent.toLowerCase();
      contacts = contacts.where((c) => 
        (c.addressLabel ?? '').toLowerCase().contains(loc)
      ).toList();
    }

    // Company Filter
    if (companyIntent != null && companyIntent.isNotEmpty) {
      final comp = companyIntent.toLowerCase();
      contacts = contacts.where((c) => 
        (c.company ?? '').toLowerCase().contains(comp)
      ).toList();
    }

    // Name Filter
    if (personIntent != null && personIntent.isNotEmpty) {
      final name = personIntent.toLowerCase();
      contacts = contacts.where((c) => 
        c.name.toLowerCase().contains(name)
      ).toList();
    }

    // 4. Semantic Ranking (The "Vibe" Check)
    if (topicIntent != null || contacts.length > 5) {
      final topic = topicIntent ?? userQuery; // Fallback to full query
      contacts = await _rankBySimilarity(contacts, topic);
    }

    return contacts;
  }

  // --- Helpers ---

  // FIX: Robustly handle dynamic types from JSON
  String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.join(' '); // Convert ["VC", "Tech"] -> "VC Tech"
    return value.toString(); // Fallback for numbers/bools
  }

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
      return {}; 
    }
  }

  Future<List<Contact>> _rankBySimilarity(List<Contact> contacts, String query) async {
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