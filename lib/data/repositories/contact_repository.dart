import 'package:isar/isar.dart';
import '../local/database/isar_service.dart';
import '../models/contact.dart';

class ContactRepository {
  final IsarService _isarService;

  ContactRepository(this._isarService);

  Future<void> saveContact(Contact contact) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.contacts.put(contact);
    });
  }

  Future<List<Contact>> getAllContacts() async {
    final isar = await _isarService.db;
    return await isar.contacts.where().sortByMetAtDesc().findAll();
  }

  Future<Contact?> getContactById(int id) async {
    final isar = await _isarService.db;
    return await isar.contacts.get(id);
  }
  
  // Basic search (Non-vector)
  Future<List<Contact>> searchByName(String query) async {
    final isar = await _isarService.db;
    return await isar.contacts
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }
  
  // Future: Add getContactsByEvent, getContactsByLocation
}