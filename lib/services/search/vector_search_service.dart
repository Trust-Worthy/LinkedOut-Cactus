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
    
    // 1. Embed the User's Query
    final queryEmbedding = await _aiService.getEmbedding(query);
    if (queryEmbedding.isEmpty) return [];

    // 2. Score Matches (Cosine Similarity)
    List<MapEntry<Contact, double>> scoredContacts = [];
    for (var contact in allContacts) {
      if (contact.embedding != null) {
        final score = VectorUtils.cosineSimilarity(queryEmbedding, contact.embedding!);
        // Only keep somewhat relevant results
        if (score > 0.3) { 
          scoredContacts.add(MapEntry(contact, score));
        }
      }
    }

    // 3. Sort & Filter
    scoredContacts.sort((a, b) => b.value.compareTo(a.value));
    return scoredContacts.take(limit).map((e) => e.key).toList();
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