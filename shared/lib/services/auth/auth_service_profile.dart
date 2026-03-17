part of '../auth_service.dart';

Future<AuthResult> _updateProfileImpl({
  required AuthService service,
  required String userId,
  String? name,
  String? phoneNumber,
  String? language,
  bool? notificationsEnabled,
}) async {
  try {
    final authEndpoints = AuthEndpoints();
    final response = await authEndpoints.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
    );

    final token = await service.getToken();
    if (token != null) {
      await service._saveAuthData(token, response.data);
    }

    return AuthResult.success(user: response.data, token: token ?? '');
  } on ApiException catch (e) {
    return AuthResult.error(_formatApiError(e));
  } catch (e) {
    return AuthResult.error('Erreur de mise à jour: ${e.toString()}');
  }
}
