part of '../auth_provider.dart';

extension AuthProviderSecurityX on AuthProvider {
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _profileService.changePassword(
        userId: _user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
        token: _token!,
      );

      if (result.success) {
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error ?? 'Erreur de modification du mot de passe';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }

  Future<bool> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _profileService.updateEmail(
        userId: _user!.id,
        newEmail: newEmail,
        password: password,
        token: _token!,
      );

      if (result.success) {
        _user = _user!.copyWith(email: newEmail);
        await _authService.updateSavedUser(_user!);
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error ?? 'Erreur de mise à jour de l\'email';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _profileService.deleteAccount(
        userId: _user!.id,
        password: password,
        token: _token!,
      );

      if (result.success) {
        await logout();
        return true;
      }

      _error = result.error ?? 'Erreur de suppression du compte';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }
}
