import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localboost_shared/services/api/api_config.dart';
import 'package:localboost_shared/services/api/api_exception.dart';

/// Base HTTP client for all API requests
///
/// Features:
/// - Automatic JWT token injection
/// - Request/response logging (debug mode)
/// - Error handling and retry logic
/// - Timeout management
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  static const String _tokenKey = 'auth_token';

  /// Singleton instance
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.normalizedBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    if (ApiConfig.enableLogging) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  /// Get the underlying Dio instance (for advanced usage)
  Dio get dio => _dio;

  /// Update auth token
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear auth token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }

  /// Multipart upload (for images, files)
  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw ApiExceptionFactory.fromDioException(e);
    }
  }
}

/// Interceptor to inject authentication token
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString('refresh_token');

      if (storedRefreshToken != null) {
        try {
          // Use a separate Dio instance to avoid interceptor loops
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiConfig.normalizedBaseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));

          final refreshResponse = await refreshDio.post(
            'auth/token/refresh/',
            data: {'refresh': storedRefreshToken},
          );

          final newAccessToken =
              refreshResponse.data['access'] as String;
          await prefs.setString('auth_token', newAccessToken);

          // Retry the original request with the new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await refreshDio.request(
            opts.path,
            data: opts.data,
            queryParameters: opts.queryParameters,
            options: Options(
              method: opts.method,
              headers: opts.headers,
            ),
          );

          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed — clear all tokens so the user is shown the login screen
          await prefs.remove('auth_token');
          await prefs.remove('refresh_token');
        }
      } else {
        await prefs.remove('auth_token');
      }
    }

    handler.next(err);
  }
}

/// Interceptor for logging requests/responses (debug mode only)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 API Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      print('📤 Request Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
    print('📥 Response Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ API Error: ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('❌ Error Message: ${err.message}');
    if (err.response != null) {
      print('❌ Error Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}

/// Interceptor for automatic retry on network failures
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const _retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    if (shouldRetry && retryCount < ApiConfig.maxRetries) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      // Wait before retry
      await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

      try {
        // Retry the request
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with the original error
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && _retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}
