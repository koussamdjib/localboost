part of '../profile_service.dart';

Future<ProfileResult> _changePasswordImpl({
  required String userId,
  required String currentPassword,
  required String newPassword,
  required String token,
}) async {
  try {
    // Keep lightweight validation client-side before hitting the API.
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      return ProfileResult.error('Les mots de passe ne peuvent pas être vides');
    }
    if (newPassword.length < 6) {
      return ProfileResult.error(
        'Le nouveau mot de passe doit contenir au moins 6 caractères',
      );
    }

    final response = await AuthEndpoints().changePassword(
      oldPassword: currentPassword,
      newPassword: newPassword,
    );

    return ProfileResult.success(
      data: response.message ?? 'Mot de passe modifié avec succès',
    );
  } on ApiException catch (e) {
    return ProfileResult.error(_formatProfileApiError(e));
  } catch (e) {
    return ProfileResult.error('Erreur de modification: ${e.toString()}');
  }
}

Future<ProfileResult> _deleteAccountImpl({
  required String userId,
  required String password,
  required String token,
}) async {
  try {
    if (password.isEmpty) {
      return ProfileResult.error(
        'Le mot de passe est requis pour supprimer le compte',
      );
    }

    await AuthEndpoints().deleteAccount();
    return ProfileResult.success(data: 'Compte supprimé avec succès');
  } on ApiException catch (e) {
    return ProfileResult.error(_formatProfileApiError(e));
  } catch (e) {
    return ProfileResult.error('Erreur de suppression: ${e.toString()}');
  }
}

Future<ProfileResult> _updateEmailImpl({
  required String userId,
  required String newEmail,
  required String password,
  required String token,
}) async {
  try {
    if (!newEmail.contains('@')) {
      return ProfileResult.error('Adresse email invalide');
    }

    if (password.isEmpty) {
      return ProfileResult.error(
        'Le mot de passe est requis pour changer l\'email',
      );
    }

    final response = await AuthEndpoints().updateEmail(
      newEmail: newEmail,
      password: password,
    );

    return ProfileResult.success(
      data: response.message ?? 'Email mis a jour avec succes.',
    );
  } catch (e) {
    return ProfileResult.error('Erreur de mise à jour: ${e.toString()}');
  }
}

String _formatProfileApiError(ApiException error) {
  if (error is NetworkException) {
    return 'Problème de connexion. Vérifiez votre connexion internet.';
  }
  if (error is AuthException) {
    return 'Session expirée. Veuillez vous reconnecter.';
  }
  if (error is ValidationException) {
    return error.allFieldErrors;
  }
  if (error is ServerException) {
    return 'Erreur du serveur. Veuillez réessayer plus tard.';
  }
  return error.message;
}
