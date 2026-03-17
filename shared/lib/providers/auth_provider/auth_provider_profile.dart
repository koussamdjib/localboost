part of '../auth_provider.dart';

extension AuthProviderProfileX on AuthProvider {
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? language,
    bool? notificationsEnabled,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _authService.updateProfile(
        userId: _user!.id,
        name: name,
        phoneNumber: phoneNumber,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      if (result.success) {
        _user = result.user;
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error;
      _isLoading = false;
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur de mise à jour: ${e.toString()}';
      _isLoading = false;
      _notifyStateChanged();
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(File photoFile) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _profileService.uploadProfilePhoto(
        userId: _user!.id,
        photoFile: photoFile,
        token: _token!,
      );

      if (result.success && result.data != null) {
        _user = _user!.copyWith(profileImageUrl: result.data as String);
        await _authService.updateSavedUser(_user!);
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error ?? 'Erreur de téléchargement';
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

  Future<bool> deleteProfilePhoto() async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _profileService.deleteProfilePhoto(
        userId: _user!.id,
        token: _token!,
      );

      if (result.success) {
        _user = _user!.copyWith(profileImageUrl: null);
        await _authService.updateSavedUser(_user!);
        _isLoading = false;
        _notifyStateChanged();
        return true;
      }

      _error = result.error ?? 'Erreur de suppression';
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
