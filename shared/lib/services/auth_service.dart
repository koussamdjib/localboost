import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/services/api/api_exception.dart';
import 'package:localboost_shared/services/api/endpoints/auth_endpoints.dart';

part 'auth/auth_service_profile.dart';
part 'auth/auth_service_api.dart';

/// Authentication service for API integration
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) =>
      _registerApiImpl(
        service: this,
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );

  /// Login existing user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) =>
      _loginApiImpl(service: this, email: email, password: password);

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('refresh_token');
  }

  /// Get saved auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get saved user data
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Save auth data to local storage
  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Update saved user data (without changing token)
  Future<void> updateSavedUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? language,
    bool? notificationsEnabled,
  }) =>
      _updateProfileImpl(
        service: this,
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

  /// Load current user from backend.
  Future<User?> loadCurrentUser() async {
    try {
      final response = await AuthEndpoints().getCurrentUser();
      await updateSavedUser(response.data);
      return response.data;
    } catch (_) {
      return null;
    }
  }
}

/// Result wrapper for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.token,
    this.error,
  });

  factory AuthResult.success({required User user, required String token}) {
    return AuthResult._(success: true, user: user, token: token);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}
