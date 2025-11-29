import 'package:flutter/foundation.dart';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';

class VectorSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;

  VectorSearchService(this._repository, this._aiService);

  /// Pure Vector Search
  /// [threshold]: 0.0 to 1.0. Higher = Stricter matches.
  /// Recommended starting point: 0.25
  Future<List<Contact>> search(String query, {double threshold = 0.25, int limit = 10}) async {
    // 1. Get All Data
    final allContacts = await _repository.getAllContacts();
    if (allContacts.isEmpty) return [];

    debugPrint('🔍 Vector Search: "$query" (Strictness: $threshold)');

    // 2. Generate Query Embedding
    final queryEmbedding = await _aiService.getEmbedding(query);
    
    // Safety: If embedding fails (empty string or model error), fallback to keyword
    if (queryEmbedding.isEmpty) {
      debugPrint('⚠️ Embedding failed/empty. Using keyword fallback.');
      return _keywordFallback(allContacts, query);
    }

    // 3. Score & Rank
    List<MapEntry<Contact, double>> scoredContacts = [];
    
    for (var contact in allContacts) {
      if (contact.embedding != null) {
        // Dimension Check
        if (contact.embedding!.length != queryEmbedding.length) {
          debugPrint('⚠️ Dimension mismatch: Contact ${contact.id} has ${contact.embedding!.length}, Query has ${queryEmbedding.length}');
          continue; 
        }

        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);
        
        // Debugging logs to help you fine-tune
        // debugPrint('   - ${contact.name}: $score'); 

        if (score > threshold) { 
          scoredContacts.add(MapEntry(contact, score));
        }
      }
    }

    // 4. Sort (Highest Score First)
    scoredContacts.sort((a, b) => b.value.compareTo(a.value));
    
    debugPrint('✅ Found ${scoredContacts.length} matches above threshold.');

    return scoredContacts.take(limit).map((e) => e.key).toList();
  }

  List<Contact> _keywordFallback(List<Contact> contacts, String query) {
    final lowerQuery = query.toLowerCase();
    return contacts.where((c) => 
      c.name.toLowerCase().contains(lowerQuery) || 
      (c.company?.toLowerCase().contains(lowerQuery) ?? false) ||
      (c.notes?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}