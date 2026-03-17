part of '../auth_provider.dart';

extension AuthProviderLoginX on AuthProvider {
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );

      if (result.success) {
        _user = result.user;
        _token = result.token;
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error;
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur d\'inscription: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        _user = result.user;
        _token = result.token;
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error;
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur de connexion: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }
}
