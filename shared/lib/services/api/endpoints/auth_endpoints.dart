import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:localboost_shared/services/api/api_response.dart';

/// Authentication API endpoints
class AuthEndpoints {
  final ApiClient _client = ApiClient.instance;

  /// Register a new user
  ///
  /// POST /auth/register/
  Future<ApiResponse<User>> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    final response = await _client.post(
      'auth/register/',
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        'role': role.name,
      },
    );

    final payload = Map<String, dynamic>.from(
      response.data as Map<String, dynamic>,
    );
    final userPayload = payload['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(payload['user'] as Map)
        : payload;

    return ApiResponse(
      data: User.fromJson(userPayload),
      statusCode: response.statusCode ?? 200,
      message: payload['message'] as String?,
    );
  }

  /// Login user and get JWT tokens
  ///
  /// POST /auth/token/
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      'auth/token/',
      data: {
        'email': email,
        'password': password,
      },
    );

    final payload = Map<String, dynamic>.from(
      response.data as Map<String, dynamic>,
    );
    final accessToken = payload['access'] as String;
    final refreshToken = payload['refresh'] as String;

    // Store access token in API client
    await _client.setAuthToken(accessToken);

    return LoginResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      statusCode: response.statusCode ?? 200,
    );
  }

  /// Refresh JWT access token
  ///
  /// POST /auth/token/refresh/
  Future<String> refreshToken(String refreshToken) async {
    final response = await _client.post(
      'auth/token/refresh/',
      data: {
        'refresh': refreshToken,
      },
    );

    final payload = Map<String, dynamic>.from(
      response.data as Map<String, dynamic>,
    );
    final newAccessToken = payload['access'] as String;

    // Update stored token
    await _client.setAuthToken(newAccessToken);

    return newAccessToken;
  }

  /// Get current user profile
  ///
  /// GET /auth/me/
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _client.get('auth/me/');

    return ApiResponse(
      data: User.fromJson(response.data),
      statusCode: response.statusCode ?? 200,
    );
  }

  /// Update current user profile
  ///
  /// PUT /auth/me/
  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    final response = await _client.put(
      'auth/me/',
      data: {
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      },
    );

    return ApiResponse(
      data: User.fromJson(response.data),
      statusCode: response.statusCode ?? 200,
      message: response.data['message'],
    );
  }

  /// Update current user email
  ///
  /// POST /auth/me/email/
  Future<ApiResponse<User>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    final response = await _client.post(
      'auth/me/email/',
      data: {
        'new_email': newEmail,
        'password': password,
      },
    );

    final payload = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map<String, dynamic>)
        : const <String, dynamic>{};
    final userPayload = payload['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(payload['user'] as Map)
        : payload;

    return ApiResponse(
      data: User.fromJson(userPayload),
      statusCode: response.statusCode ?? 200,
      message: payload['message'] as String?,
    );
  }

  /// Change password
  ///
  /// POST /auth/me/password/
  Future<EmptyResponse> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _client.post(
      'auth/me/password/',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    final payload = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map<String, dynamic>)
        : const <String, dynamic>{};

    return EmptyResponse(
      statusCode: response.statusCode ?? 200,
      message: payload['message'] as String?,
    );
  }

  /// Delete account
  ///
  /// DELETE /auth/me/
  Future<EmptyResponse> deleteAccount() async {
    final response = await _client.delete('auth/me/');

    // Clear auth token after account deletion
    await _client.clearAuthToken();

    final payload = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map<String, dynamic>)
        : const <String, dynamic>{};

    return EmptyResponse(
      statusCode: response.statusCode ?? 204,
      message: payload['message'] as String?,
    );
  }

  /// Logout (clear local token)
  ///
  /// Note: This is a client-side operation.
  /// For server-side logout (token blacklist), implement POST /auth/logout/
  Future<void> logout() async {
    await _client.clearAuthToken();
  }
}

/// Login response containing tokens
class LoginResponse extends ApiResponse<void> {
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required super.statusCode,
    super.message,
  }) : super(data: null);
}
