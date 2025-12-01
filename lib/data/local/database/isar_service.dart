import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/contact.dart';
import '../../models/user.dart';

class IsarService {
  late Future<Isar> db;

  // Singleton Pattern
  static final IsarService _instance = IsarService._internal();
  
  // Factory constructor returns the singleton instance
  factory IsarService() => _instance;
  
  // Static getter for easy access
  static IsarService get instance => _instance;

  // Store user databases separately
  final Map<String, Isar> _userDatabases = {};
  Isar? _authDatabase;

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

  /// Get the authentication database (stores User accounts)
  Future<Isar> getAuthDatabase() async {
    if (_authDatabase != null) {
      return _authDatabase!;
    }

    final dir = await getApplicationDocumentsDirectory();
    
    _authDatabase = await Isar.open(
      [UserSchema],
      directory: dir.path,
      name: 'linkedout_auth',
      inspector: true,
    );

    return _authDatabase!;
  }

  /// Get or create a user-specific database for contacts
  Future<Isar> getUserDatabase(String username) async {
    // Check if database already exists
    if (_userDatabases.containsKey(username)) {
      return _userDatabases[username]!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbName = 'linkedout_$username';

    final userDb = await Isar.open(
      [ContactSchema],
      directory: dir.path,
      name: dbName,
      inspector: true,
    );

    _userDatabases[username] = userDb;
    
    // Update the main db reference to point to current user's database
    db = Future.value(userDb);

    return userDb;
  }

  /// Switch to a specific user's database
  Future<void> switchUserDatabase(String username) async {
    final userDb = await getUserDatabase(username);
    db = Future.value(userDb);
  }

  /// Close user database when logging out
  Future<void> closeUserDatabase(String username) async {
    if (_userDatabases.containsKey(username)) {
      await _userDatabases[username]!.close();
      _userDatabases.remove(username);
    }
  }

  // --- Helper: Clean Database (Useful for demos) ---
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}