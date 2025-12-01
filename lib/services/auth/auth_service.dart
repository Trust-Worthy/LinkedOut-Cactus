import 'package:crypto/crypto.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/user.dart';
import '../../data/local/database/isar_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;

  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Get the auth database (separate from contact data)
  Future<Isar> get _authDb async {
    return await IsarService.instance.getAuthDatabase();
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Register a new user
  Future<bool> register({
    required String username,
    required String password,
    String? displayName,
    String? email,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final isar = await _authDb;

      // Check if username already exists
      final existingUser = await isar.users
          .filter()
          .usernameEqualTo(username, caseSensitive: false)
          .findFirst();

      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      // Create new user with hashed password
      final newUser = User(
        username: username,
        passwordHash: _hashPassword(password),
        displayName: displayName ?? username,
        email: email,
      );

      await isar.writeTxn(() async {
        await isar.users.put(newUser);
      });

      return true;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login with username and password
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }

      final isar = await _authDb;

      // Find user by username
      final user = await isar.users
          .filter()
          .usernameEqualTo(username, caseSensitive: false)
          .findFirst();

      if (user == null) {
        throw Exception('Invalid username or password');
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        throw Exception('Invalid username or password');
      }

      // Update last login time
      user.lastLoginAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.users.put(user);
      });

      // Store current user session
      _currentUser = user;
      await _saveSession(user.username);

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Save session to SharedPreferences
  Future<void> _saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', username);
  }

  /// Restore session from SharedPreferences
  Future<User?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('current_user');

      if (username == null) {
        return null;
      }

      final isar = await _authDb;
      final user = await isar.users
          .filter()
          .usernameEqualTo(username, caseSensitive: false)
          .findFirst();

      if (user != null) {
        _currentUser = user;
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _currentUser = null;
  }

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Get user's database name (for separating data per user)
  String getUserDatabaseName(String username) {
    return 'linkedout_$username';
  }

  /// Update onboarding status
  Future<void> completeOnboarding() async {
    if (_currentUser == null) return;

    final isar = await _authDb;
    _currentUser!.hasCompletedOnboarding = true;

    await isar.writeTxn(() async {
      await isar.users.put(_currentUser!);
    });
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return _currentUser?.hasCompletedOnboarding ?? false;
  }

  /// Delete user account
  Future<void> deleteAccount(String password) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Verify password before deletion
    final hashedPassword = _hashPassword(password);
    if (_currentUser!.passwordHash != hashedPassword) {
      throw Exception('Invalid password');
    }

    final isar = await _authDb;
    await isar.writeTxn(() async {
      await isar.users.delete(_currentUser!.id);
    });

    await logout();
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Verify current password
    final currentHash = _hashPassword(currentPassword);
    if (_currentUser!.passwordHash != currentHash) {
      throw Exception('Current password is incorrect');
    }

    // Update to new password
    _currentUser!.passwordHash = _hashPassword(newPassword);

    final isar = await _authDb;
    await isar.writeTxn(() async {
      await isar.users.put(_currentUser!);
    });
  }
}
