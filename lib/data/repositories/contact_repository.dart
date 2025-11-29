import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../local/database/isar_service.dart';
import '../models/contact.dart';
import '../../services/ai/cactus_service.dart';

class ContactRepository {
  final IsarService _isarService;

  ContactRepository(this._isarService);

  Future<void> saveContact(Contact contact) async {
    final isar = await _isarService.db;

    final String textToEmbed = _buildContactText(contact);

    try {
      // Only generate if not already present or if you want to force update
      // For now, we always generate to ensure freshness
      final embedding = await CactusService.instance.getEmbedding(textToEmbed);
      if (embedding.isNotEmpty) {
        contact.embedding = embedding;
      }
    } catch (e) {
      debugPrint("Warning: Failed to generate embedding: $e");
    }

    await isar.writeTxn(() async {
      await isar.contacts.put(contact);
    });
  }

  /// REGENERATION LOGIC: Call this to fix incompatible embeddings
  Future<void> regenerateAllEmbeddings() async {
    final isar = await _isarService.db;
    final allContacts = await isar.contacts.where().findAll();
    
    debugPrint('🔄 Regenerating embeddings for ${allContacts.length} contacts...');
    
    await isar.writeTxn(() async {
      for (var contact in allContacts) {
        try {
          final text = _buildContactText(contact);
          final embedding = await CactusService.instance.getEmbedding(text);
          
          if (embedding.isNotEmpty) {
            contact.embedding = embedding;
            await isar.contacts.put(contact); // Update existing record
            debugPrint('✅ Updated embedding for ${contact.name}');
          } else {
            debugPrint('⚠️ Empty embedding generated for ${contact.name}');
          }
        } catch (e) {
          debugPrint('❌ Error updating ${contact.name}: $e');
        }
      }
    });
    debugPrint('✨ Done! All embeddings regenerated.');
  }

  String _buildContactText(Contact contact) {
    return """
      Name: ${contact.name}
      Company: ${contact.company ?? ''}
      Title: ${contact.title ?? ''}
      Notes: ${contact.notes ?? ''}
      Location: ${contact.addressLabel ?? ''}
      Event: ${contact.eventName ?? ''}
      Tags: ${contact.tags?.join(', ') ?? ''}
    """.trim();
  }

  Future<List<Contact>> getAllContacts() async {
    final isar = await _isarService.db;
    return await isar.contacts.where().sortByMetAtDesc().findAll();
  }

  Future<void> deleteContact(int id) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.contacts.delete(id);
    });
  }
}