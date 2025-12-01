import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/models/auth_state.dart';
import 'auth_service.dart';
import '../../data/local/database/isar_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final IsarService _isarService = IsarService.instance;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;

  /// Initialize auth state on app start
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final user = await _authService.restoreSession();
      
      if (user != null) {
        _currentUser = user;
        // Switch to user's database
        await _isarService.switchUserDatabase(user.username);
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _errorMessage = 'Failed to restore session: $e';
      _setState(AuthState.unauthenticated);
    }
  }

  /// Login with credentials
  Future<bool> login(String username, String password) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      final user = await _authService.login(
        username: username,
        password: password,
      );

      _currentUser = user;
      
      // Switch to user's database
      await _isarService.switchUserDatabase(user.username);
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AuthState.error);
      
      // Reset to unauthenticated after showing error
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state == AuthState.error) {
          _setState(AuthState.unauthenticated);
        }
      });
      
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String username,
    required String password,
    String? displayName,
    String? email,
  }) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      await _authService.register(
        username: username,
        password: password,
        displayName: displayName,
        email: email,
      );

      // After registration, log the user in
      return await login(username, password);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AuthState.error);
      
      // Reset to unauthenticated after showing error
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state == AuthState.error) {
          _setState(AuthState.unauthenticated);
        }
      });
      
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    if (_currentUser != null) {
      await _isarService.closeUserDatabase(_currentUser!.username);
    }
    
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
  }

  /// Complete onboarding for current user
  Future<void> completeOnboarding() async {
    await _authService.completeOnboarding();
    notifyListeners();
  }

  /// Check if current user has completed onboarding
  bool get hasCompletedOnboarding {
    return _authService.hasCompletedOnboarding;
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    _errorMessage = null;

    try {
      await _authService.deleteAccount(password);
      _currentUser = null;
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
