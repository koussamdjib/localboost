part of '../auth_service.dart';

/// API implementation for authentication flows.

const String _refreshTokenKey = 'refresh_token';

Future<AuthResult> _registerApiImpl({
  required AuthService service,
  required String email,
  required String password,
  required String name,
  String? phoneNumber,
  required UserRole role,
}) async {
  try {
    final authEndpoints = AuthEndpoints();
    
    // Call the registration endpoint
    final response = await authEndpoints.register(
      email: email,
      password: password,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
    );

    final user = response.data;

    // After registration, automatically login to get tokens
    final loginResponse = await authEndpoints.login(
      email: email,
      password: password,
    );

    // Save user data and token
    await service._saveAuthData(loginResponse.accessToken, user);
    // Save refresh token for automatic token renewal
    final registerPrefs = await SharedPreferences.getInstance();
    await registerPrefs.setString(_refreshTokenKey, loginResponse.refreshToken);

    return AuthResult.success(
      user: user,
      token: loginResponse.accessToken,
    );
  } on ApiException catch (e) {
    return AuthResult.error(_formatApiError(e));
  } catch (e) {
    return AuthResult.error('Erreur inattendue: ${e.toString()}');
  }
}

Future<AuthResult> _loginApiImpl({
  required AuthService service,
  required String email,
  required String password,
}) async {
  try {
    final authEndpoints = AuthEndpoints();

    // Call the login endpoint
    final loginResponse = await authEndpoints.login(
      email: email,
      password: password,
    );

    // Fetch user profile after successful login
    final userResponse = await authEndpoints.getCurrentUser();
    final user = userResponse.data;

    // Save user data and token
    await service._saveAuthData(loginResponse.accessToken, user);
    // Save refresh token for automatic token renewal
    final loginPrefs = await SharedPreferences.getInstance();
    await loginPrefs.setString(_refreshTokenKey, loginResponse.refreshToken);

    return AuthResult.success(
      user: user,
      token: loginResponse.accessToken,
    );
  } on ApiException catch (e) {
    return AuthResult.error(_formatApiError(e));
  } catch (e) {
    return AuthResult.error('Erreur de connexion: ${e.toString()}');
  }
}

// Logout is handled by AuthService.logout() directly
// No API call needed for logout in current implementation

/// Format API exception to user-friendly error message
String _formatApiError(ApiException error) {
  if (error is NetworkException) {
    return 'Problème de connexion. Vérifiez votre connexion internet.';
  } else if (error is AuthException) {
    return 'Email ou mot de passe incorrect.';
  } else if (error is ValidationException) {
    return error.allFieldErrors;
  } else if (error is ServerException) {
    return 'Erreur du serveur. Veuillez réessayer plus tard.';
  } else {
    return error.message;
  }
}
