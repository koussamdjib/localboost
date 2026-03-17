import 'dart:io';
import 'package:localboost_shared/services/api/api_exception.dart';
import 'package:localboost_shared/services/api/endpoints/auth_endpoints.dart';

part 'profile/profile_service_photo.dart';
part 'profile/profile_service_security.dart';

/// Profile management service for advanced operations
///
/// Handles profile photo upload, password changes, and account deletion
class ProfileService {  /// Upload profile photo
  ///
  /// Returns the URL of the uploaded photo
  Future<ProfileResult> uploadProfilePhoto({
    required String userId,
    required File photoFile,
    required String token,
  }) =>
      _uploadProfilePhotoImpl(
        userId: userId,
        photoFile: photoFile,
        token: token,
      );

  /// Delete profile photo
  Future<ProfileResult> deleteProfilePhoto({
    required String userId,
    required String token,
  }) =>
      _deleteProfilePhotoImpl(userId: userId, token: token);

  /// Change user password
  Future<ProfileResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String token,
  }) =>
      _changePasswordImpl(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        token: token,
      );

  /// Delete user account
  ///
  /// This is a destructive operation - requires confirmation
  Future<ProfileResult> deleteAccount({
    required String userId,
    required String password,
    required String token,
  }) =>
      _deleteAccountImpl(userId: userId, password: password, token: token);

  /// Update email address
  ///
  /// May require email verification
  Future<ProfileResult> updateEmail({
    required String userId,
    required String newEmail,
    required String password,
    required String token,
  }) =>
      _updateEmailImpl(
        userId: userId,
        newEmail: newEmail,
        password: password,
        token: token,
      );
}

/// Result wrapper for profile operations
class ProfileResult {
  final bool success;
  final dynamic data;
  final String? error;

  ProfileResult._({
    required this.success,
    this.data,
    this.error,
  });

  factory ProfileResult.success({dynamic data}) {
    return ProfileResult._(success: true, data: data);
  }

  factory ProfileResult.error(String error) {
    return ProfileResult._(success: false, error: error);
  }
}
