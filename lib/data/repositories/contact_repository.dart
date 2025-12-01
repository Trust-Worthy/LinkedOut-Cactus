import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../local/database/isar_service.dart';
import '../models/contact.dart';
import '../../services/ai/cactus_service.dart';

class ContactRepository {
  final IsarService _isarService;

  ContactRepository(this._isarService);

  // --- User Profile Methods (NEW) ---

  /// Gets the user's profile. Returns null if not set up yet.
  Future<Contact?> getUserProfile() async {
    final isar = await _isarService.db;
    return await isar.contacts.filter().isMeEqualTo(true).findFirst();
  }

  /// Saves the user profile and generates its embedding context
  Future<void> saveUserProfile(Contact profile) async {
    profile.isMe = true; // Enforce this flag
    await saveContact(profile); 
  }

  // --- Existing Methods ---

  Future<void> saveContact(Contact contact) async {
    final isar = await _isarService.db;

    // Build context string including "MY PROFILE" tag if it's the user
    String textToEmbed = _buildContactText(contact);
    if (contact.isMe) {
      textToEmbed = "MY USER PROFILE (ME): $textToEmbed";
    }

    try {
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

  // UPDATED: Filter out the user's own profile from the main list
  Future<List<Contact>> getAllContacts() async {
    final isar = await _isarService.db;
    return await isar.contacts
        .filter()
        .isMeEqualTo(false) // Don't show "Me" in the main list
        .sortByMetAtDesc()
        .findAll();
  }
  
  String _buildContactText(Contact contact) {
    return """
      Name: ${contact.name}
      Company: ${contact.company ?? ''}
      Title: ${contact.title ?? ''}
      Notes: ${contact.notes ?? ''}
      Location: ${contact.addressLabel ?? ''}
      Event: ${contact.eventName ?? ''}
    """.trim();
  }
  
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
            await isar.contacts.put(contact); 
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
  
  Future<void> deleteContact(int id) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.contacts.delete(id);
    });
  }
}