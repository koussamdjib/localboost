/// API configuration and feature flags
///
/// Controls backend connectivity.
/// Use environment variables to configure for different build variants.
class ApiConfig {
  /// Base URL for the Django backend API
  ///
  /// Override with: `--dart-define=API_BASE_URL=https://your-api.com/api/v1`
  /// Default: LocalBoost production API prefix.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sirius-djibouti.com/api/v1',
  );

  /// Normalized base URL with trailing slash to avoid path resolution issues.
  static String get normalizedBaseUrl =>
      baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Connection timeout duration
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Enable debug logging for API requests/responses
  ///
  /// Override with: `--dart-define=API_DEBUG=false`
  /// Default: `true` in non-production builds
  static const bool enableLogging = bool.fromEnvironment(
    'API_DEBUG',
    defaultValue: true,
  );

  /// Maximum retry attempts for failed requests
  static const int maxRetries = 3;

  /// Delay between retry attempts
  static const Duration retryDelay = Duration(seconds: 2);
}
