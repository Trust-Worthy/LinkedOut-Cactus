import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/utils/vector_utils.dart';
import '../ai/cactus_service.dart';

class VectorSearchService {
  final ContactRepository _repository;
  final CactusService _aiService;

  VectorSearchService(this._repository, this._aiService);

  /// 1. SEMANTIC SEARCH
  /// Returns contacts ranked by relevance to the query.
  Future<List<Contact>> search(String query, {int limit = 5}) async {
    // A. Get all contacts 
    final allContacts = await _repository.getAllContacts();
    
    // B. Generate embedding for the USER'S QUERY
    final queryEmbedding = await _aiService.getEmbedding(query);
    
    if (queryEmbedding.isEmpty) return [];

    // C. Score every contact
    // We create a list of (Contact, Score) pairs
    List<MapEntry<Contact, double>> scoredContacts = [];

    for (var contact in allContacts) {
      if (contact.embedding != null) {
        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);
        scoredContacts.add(MapEntry(contact, score));
      }
    }

    // D. Sort by score (Highest first)
    scoredContacts.sort((a, b) => b.value.compareTo(a.value));

    // E. Return top N matches
    return scoredContacts.take(limit).map((e) => e.key).toList();
  }

  /// 2. RAG GENERATION
  /// "Who did I meet in SF?" -> Finds contacts -> Returns natural language answer.
  Future<String> askYourNetwork(String userQuestion) async {
    // Step 1: Retrieval
    final relevantContacts = await search(userQuestion, limit: 5);
    
    if (relevantContacts.isEmpty) {
      return "I couldn't find anyone in your network matching that description.";
    }

    // Step 2: Context Construction
    // We create a mini-prompt containing the data we found
    String contextData = relevantContacts.map((c) => 
      "- ${c.name} (${c.title} at ${c.company}). Met at: ${c.addressLabel}. Notes: ${c.notes}"
    ).join("\n");

    // Step 3: Return Context (for now)
    return "Found ${relevantContacts.length} relevant contacts:\n$contextData"; 
  }
}