import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cactus/cactus.dart';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';
import '../location/offline_geocoding_service.dart';

// ==========================================
// 1. DATA MODELS
// ==========================================

class QueryParameters {
  final String? locationType;
  final String? locationName;
  final double? radiusMiles;
  final double? radiusKm;
  final String? timeframeType;
  final String? timeframeValue;
  final String? abstractConcept;
  final String? personAttribute;
  final int? limit;
  
  QueryParameters({
    this.locationType,
    this.locationName,
    this.radiusMiles,
    this.radiusKm,
    this.timeframeType,
    this.timeframeValue,
    this.abstractConcept,
    this.personAttribute,
    this.limit,
  });
  
  bool get hasLocation => locationName != null;
  bool get hasRadius => radiusMiles != null || radiusKm != null;
  bool get hasTimeframe => timeframeValue != null;
  bool get hasAbstractConcept => abstractConcept != null;
}

class ContactWithScore {
  final Contact contact;
  double score;
  String reason;
  
  ContactWithScore({
    required this.contact,
    required this.score,
    required this.reason,
  });
}

class AdvancedSearchResult {
  final List<Contact> contacts;
  final List<ContactWithScore>? scoredContacts;
  final String query;
  final QueryParameters parameters;
  final String summary;
  
  AdvancedSearchResult({
    required this.contacts,
    this.scoredContacts,
    required this.query,
    required this.parameters,
    required this.summary,
  });
  
  bool get hasScores => scoredContacts != null && scoredContacts!.isNotEmpty;
}

// ==========================================
// 2. QUERY PARSER (LLM)
// ==========================================

class AdvancedQueryParser {
  final CactusService _aiService;

  AdvancedQueryParser(this._aiService);
  
  Future<QueryParameters> parseAdvancedQuery(String query) async {
    final prompt = """Analyze this search query and extract ALL parameters.

Query: "$query"

Extract these fields (use null if not mentioned):
1. location_name: (city/place name if mentioned)
2. radius_miles: (number if "within X miles" mentioned, else null)
3. timeframe_type: (exact_date|relative|range|null)
4. timeframe_value: (e.g., "1 year ago", "last 6 months", "2023-01-15")
5. abstract_concept: (e.g., "VC connections", "startup founders", "investors")
6. limit: (number if "top 5" or "list 10" mentioned, else null)

Return ONLY valid JSON. Example:
{"location_name":"Denver","radius_miles":20, "abstract_concept":"investor"}
""";

    try {
      final response = await _aiService.generateChatResponse([
        ChatMessage(role: "user", content: prompt)
      ]);
      return _parseQueryParameters(response);
    } catch (e) {
      debugPrint("Query parsing failed: $e");
      return QueryParameters();
    }
  }
  
  QueryParameters _parseQueryParameters(String llmOutput) {
    try {
      String cleaned = llmOutput.trim()
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '');
      
      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace >= 0 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }
      
      final json = jsonDecode(cleaned);
      
      return QueryParameters(
        locationName: json['location_name'],
        radiusMiles: json['radius_miles'] is num ? (json['radius_miles'] as num).toDouble() : null,
        timeframeType: json['timeframe_type'],
        timeframeValue: json['timeframe_value'],
        abstractConcept: json['abstract_concept'],
        limit: json['limit'] is num ? (json['limit'] as num).toInt() : null,
      );
    } catch (e) {
      return QueryParameters(); 
    }
  }
}

// ==========================================
// 3. SPATIAL SEARCH (Geocoding + Math)
// ==========================================

class SpatialSearchService {
  // Search within radius
  Future<List<Contact>> searchWithinRadius({
    required String centerLocation,
    required double radiusMiles,
    required List<Contact> allContacts,
  }) async {
    debugPrint('🗺️ Searching within $radiusMiles miles of $centerLocation');
    
    // 1. Geocode the center location (Offline)
    final coords = await OfflineGeocodingService.instance.getCoordinates(centerLocation);
    
    if (coords == null) {
      debugPrint('❌ Could not geocode: $centerLocation');
      return [];
    }
    
    final centerLat = coords['lat']!;
    final centerLng = coords['lng']!;
    
    // 2. Filter contacts by distance
    final radiusKm = radiusMiles * 1.60934; 
    
    List<Contact> withinRadius = [];
    
    for (var contact in allContacts) {
      if (contact.latitude == null || contact.longitude == null) continue;
      
      final distance = _calculateDistance(
        centerLat, centerLng,
        contact.latitude!, contact.longitude!,
      );
      
      if (distance <= radiusKm) {
        withinRadius.add(contact);
      }
    }
    return withinRadius;
  }
  
  // Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
  
  double _toRadians(double degrees) => degrees * pi / 180;
}

// ==========================================
// 4. TEMPORAL SEARCH (Date Parsing)
// ==========================================

class TemporalSearchService {
  Future<List<Contact>> searchByTimeframe({
    required String timeframeType,
    required String timeframeValue,
    required List<Contact> allContacts,
  }) async {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;
    
    final lowerVal = timeframeValue.toLowerCase();

    // Very simple heuristic parsing for Hackathon
    if (lowerVal.contains("year")) {
      startDate = now.subtract(const Duration(days: 365));
    } else if (lowerVal.contains("month")) {
      // Assume "last X months" or "a month ago" -> default to 30 days
      startDate = now.subtract(const Duration(days: 30));
    } else if (lowerVal.contains("week")) {
      startDate = now.subtract(const Duration(days: 7));
    }
    
    if (startDate == null) return allContacts; // Fallback if parse fails
    
    return allContacts.where((contact) {
      return contact.metAt.isAfter(startDate!);
    }).toList();
  }
}

// ==========================================
// 5. CONCEPT SEARCH (Vector Embeddings)
// ==========================================

class AbstractConceptSearchService {
  final CactusService _aiService;
  
  AbstractConceptSearchService(this._aiService);

  Future<List<ContactWithScore>> searchByAbstractConcept({
    required String concept,
    required List<Contact> contacts,
  }) async {
    debugPrint('🧠 Searching for abstract concept: $concept');
    
    // Generate embedding for the concept
    final conceptEmbedding = await _aiService.getEmbedding(concept);
    
    if (conceptEmbedding.isEmpty) return [];
    
    List<ContactWithScore> scored = [];
    
    for (var contact in contacts) {
      if (contact.embedding != null) {
        if (contact.embedding!.length != conceptEmbedding.length) continue;

        final score = VectorUtils.cosineSimilarity(conceptEmbedding, contact.embedding!);
        
        // Lower threshold for abstract concepts
        if (score > 0.15) {
            scored.add(ContactWithScore(
            contact: contact,
            score: score,
            reason: 'Matches "$concept"',
            ));
        }
      }
    }
    
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}

// ==========================================
// 6. MASTER SERVICE (The Coordinator)
// ==========================================

class AdvancedSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;
  
  late final AdvancedQueryParser _parser;
  late final SpatialSearchService _spatial;
  late final TemporalSearchService _temporal;
  late final AbstractConceptSearchService _abstract;

  AdvancedSearchService(this._repository, this._aiService) {
    _parser = AdvancedQueryParser(_aiService);
    _spatial = SpatialSearchService();
    _temporal = TemporalSearchService();
    _abstract = AbstractConceptSearchService(_aiService);
  }
  
  Future<AdvancedSearchResult> executeAdvancedQuery(String query) async {
    debugPrint('\n🚀 Executing advanced query: "$query"\n');
    
    // 1. Parse
    final params = await _parser.parseAdvancedQuery(query);
    
    // 2. Start with all contacts
    var results = await _repository.getAllContacts();
    
    // 3. Spatial Filter
    if (params.hasLocation && params.hasRadius) {
      results = await _spatial.searchWithinRadius(
        centerLocation: params.locationName!,
        radiusMiles: params.radiusMiles ?? (params.radiusKm ?? 10) * 0.621371,
        allContacts: results,
      );
    } else if (params.hasLocation) {
       // Simple string match if no radius
       results = results.where((c) => 
         (c.addressLabel ?? "").toLowerCase().contains(params.locationName!.toLowerCase())
       ).toList();
    }
    
    // 4. Temporal Filter
    if (params.hasTimeframe) {
      results = await _temporal.searchByTimeframe(
        timeframeType: params.timeframeType ?? 'relative',
        timeframeValue: params.timeframeValue!,
        allContacts: results,
      );
    }
    
    // 5. Semantic Filter (Concept)
    List<ContactWithScore>? scoredResults;
    
    if (params.hasAbstractConcept) {
       scoredResults = await _abstract.searchByAbstractConcept(
         concept: params.abstractConcept!,
         contacts: results,
       );
       
       // Apply Limit
       int limit = params.limit ?? 10;
       if (scoredResults.length > limit) {
         scoredResults = scoredResults.take(limit).toList();
       }
    }
    
    return AdvancedSearchResult(
      contacts: scoredResults?.map((s) => s.contact).toList() ?? results,
      scoredContacts: scoredResults,
      query: query,
      parameters: params,
      summary: _buildSummary(params, scoredResults ?? [], results),
    );
  }
  
  String _buildSummary(QueryParameters params, List<ContactWithScore> scored, List<Contact> unscored) {
    final count = scored.isNotEmpty ? scored.length : unscored.length;
    if (count == 0) return 'No matches found.';
    
    String summary = 'Found $count contact${count == 1 ? '' : 's'}';
    if (params.hasLocation) summary += ' in/near ${params.locationName}';
    if (params.hasAbstractConcept) summary += ' matching "${params.abstractConcept}"';
    return summary;
  }
}