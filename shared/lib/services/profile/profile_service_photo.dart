part of '../profile_service.dart';

Future<ProfileResult> _uploadProfilePhotoImpl({
  required String userId,
  required File photoFile,
  required String token,
}) async {
  return ProfileResult.error(
    'Upload photo indisponible: endpoint backend non connecté.',
  );
}

Future<ProfileResult> _deleteProfilePhotoImpl({
  required String userId,
  required String token,
}) async {
  return ProfileResult.error(
    'Suppression photo indisponible: endpoint backend non connecté.',
  );
}
