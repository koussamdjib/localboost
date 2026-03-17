part of '../auth_provider.dart';

extension AuthProviderSessionX on AuthProvider {
  Future<void> initializeAuth() async {
    _isLoading = true;
    _notifyStateChanged();

    try {
      final savedUser = await _authService.getSavedUser();
      final savedToken = await _authService.getToken();

      if (savedToken != null) {
        _token = savedToken;
        _user = savedUser;

        // In API mode, refresh user state from /auth/me/ when possible.
        final currentUser = await _authService.loadCurrentUser();
        if (currentUser != null) {
          _user = currentUser;
        }
      }
    } catch (e) {
      _error = 'Erreur d\'initialisation: ${e.toString()}';
    }

    _isLoading = false;
    _notifyStateChanged();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    _error = null;
    _notifyStateChanged();
  }

  void clearError() {
    _error = null;
    _notifyStateChanged();
  }
}
