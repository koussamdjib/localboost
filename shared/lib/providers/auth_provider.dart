import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/services/auth_service.dart';
import 'package:localboost_shared/services/profile_service.dart';

part 'auth_provider/auth_provider_session.dart';
part 'auth_provider/auth_provider_login.dart';
part 'auth_provider/auth_provider_profile.dart';
part 'auth_provider/auth_provider_security.dart';

/// Authentication state management using ChangeNotifier
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  void _notifyStateChanged() {
    notifyListeners();
  }
}
