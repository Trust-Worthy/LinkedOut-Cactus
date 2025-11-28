import 'package:isar/isar.dart';
import '../local/database/isar_service.dart';
import '../models/contact.dart';
import '../../services/ai/cactus_service.dart';

class ContactRepository {
  final IsarService _isarService;

  ContactRepository(this._isarService);

  /// Saves a contact and auto-generates its AI embedding
  Future<void> saveContact(Contact contact) async {
    final isar = await _isarService.db;

    // 1. Prepare text for embedding
    // We combine important fields so the AI understands the full context
    final String textToEmbed = """
      Name: ${contact.name}
      Company: ${contact.company ?? ''}
      Title: ${contact.title ?? ''}
      Notes: ${contact.notes ?? ''}
      Location: ${contact.addressLabel ?? ''}
      Event: ${contact.eventName ?? ''}
      Tags: ${contact.tags?.join(', ') ?? ''}
    """.trim();

    // 2. Generate Embedding via Cactus
    // We do this BEFORE writing to DB
    try {
      final embedding = await CactusService.instance.getEmbedding(textToEmbed);
      if (embedding.isNotEmpty) {
        contact.embedding = embedding;
      }
    } catch (e) {
      print("Warning: Failed to generate embedding: $e");
      // We proceed to save anyway, so we don't lose user data
    }

    // 3. Save to Isar
    await isar.writeTxn(() async {
      await isar.contacts.put(contact);
    });
  }

  Future<List<Contact>> getAllContacts() async {
    final isar = await _isarService.db;
    return await isar.contacts.where().sortByMetAtDesc().findAll();
  }

  /// Delete a contact
  Future<void> deleteContact(int id) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.contacts.delete(id);
    });
  }
}