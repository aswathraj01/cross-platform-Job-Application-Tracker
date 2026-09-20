import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  String get token => _user?.token ?? '';

  /// Try to auto-login from saved session on app start.
  ///
  /// Firebase ID tokens expire after 1 hour. Instead of restoring the cached
  /// (likely-expired) token, we immediately refresh it using the refresh token
  /// so every session start uses a fresh, valid ID token.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final uid          = prefs.getString('uid');
    final email        = prefs.getString('email');
    final token        = prefs.getString('token');
    final refreshToken = prefs.getString('refresh_token') ?? '';

    if (uid == null || email == null || token == null) return;

    // Restore the user first (so _user is set for refreshIfNeeded)
    _user = UserModel(uid: uid, email: email, token: token, refreshToken: refreshToken);

    // Proactively refresh the ID token to avoid using a stale/expired one.
    if (refreshToken.isNotEmpty) {
      try {
        final refreshed = await _authService.refreshToken(_user!);
        _user = refreshed;
        await _saveUserData();
      } catch (_) {
        // Refresh token expired or invalid — clear session and force re-login
        _user = null;
        await prefs.clear();
      }
    }

    notifyListeners();
  }

  /// Login with email and password.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      await _saveUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password.
  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signup(email, password);
      await _saveUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Silently refresh the ID token using the stored refresh token.
  /// Returns the new token string, or empty string if refresh fails.
  /// Called automatically by services when a 401 is received.
  Future<String> refreshIfNeeded() async {
    if (_user == null) return '';
    try {
      final refreshed = await _authService.refreshToken(_user!);
      _user = refreshed;
      await _saveUserData();
      notifyListeners();
      return refreshed.token;
    } catch (_) {
      // Refresh token itself expired — force logout
      await logout();
      return '';
    }
  }

  /// Logout and clear saved data.
  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// Save user data to SharedPreferences for persistent sessions.
  Future<void> _saveUserData() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid',           _user!.uid);
    await prefs.setString('email',         _user!.email);
    await prefs.setString('token',         _user!.token);
    await prefs.setString('refresh_token', _user!.refreshToken);
  }

  /// Clear any error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
