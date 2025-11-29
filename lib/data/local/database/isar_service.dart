import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/contact.dart';

class IsarService {
  late Future<Isar> db;

  // Singleton Pattern
  static final IsarService _instance = IsarService._internal();
  
  // Factory constructor returns the singleton instance
  factory IsarService() => _instance;
  
  // Static getter for easy access
  static IsarService get instance => _instance;

  // Private named constructor: logic goes here
  IsarService._internal() {
    db = openIsar();
  }

  Future<Isar> openIsar() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      
      return await Isar.open(
        [
          ContactSchema, // We register the Contact schema here
        ],
        directory: dir.path,
        inspector: true, // Allows you to inspect DB in dev mode
      );
    }
    return Future.value(Isar.getInstance());
  }

  // --- Helper: Clean Database (Useful for demos) ---
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}