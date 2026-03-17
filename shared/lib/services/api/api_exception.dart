import 'package:dio/dio.dart';

/// Base exception for all API-related errors
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Network connectivity error (no internet, timeout, etc.)
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// Server returned 4xx error (bad request, unauthorized, etc.)
class ClientException extends ApiException {
  ClientException(super.message, {super.statusCode, super.data});
}

/// Server returned 5xx error (internal server error, etc.)
class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode, super.data});
}

/// Authentication error (401, 403)
class AuthException extends ApiException {
  AuthException(super.message, {super.statusCode, super.data});
}

/// Resource not found (404)
class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.statusCode, super.data});
}

/// Validation error (422, 400 with validation details)
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException(
    super.message, {
    super.statusCode,
    super.data,
    this.fieldErrors,
  });

  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    final errors = fieldErrors?[fieldName];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  /// Get all field error messages concatenated
  String get allFieldErrors {
    if (fieldErrors == null || fieldErrors!.isEmpty) return message;
    return fieldErrors!.entries
        .map((e) => '${e.key}: ${e.value.join(", ")}')
        .join('\n');
  }
}

/// Parse error (malformed response, deserialization failure)
class ParseException extends ApiException {
  ParseException(super.message, {super.data});
}

/// Request cancelled by user/app
class CancelledException extends ApiException {
  CancelledException(super.message);
}

/// Unknown error
class UnknownException extends ApiException {
  UnknownException(super.message, {super.statusCode, super.data});
}

/// Exception factory: Convert DioException to domain exception
class ApiExceptionFactory {
  static ApiException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network settings.');

      case DioExceptionType.badResponse:
        return _fromStatusCode(error);

      case DioExceptionType.cancel:
        return CancelledException('Request was cancelled');

      case DioExceptionType.badCertificate:
        return NetworkException('SSL certificate verification failed');

      case DioExceptionType.unknown:
        return UnknownException(
          error.message ?? 'An unexpected error occurred',
          data: error.response?.data,
        );
    }
  }

  static ApiException _fromStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final message = _extractErrorMessage(data) ?? 'Request failed';

    switch (statusCode) {
      case 400:
        return ClientException(
          message,
          statusCode: statusCode,
          data: data,
        );

      case 401:
      case 403:
        return AuthException(
          statusCode == 401 ? 'Authentication required' : 'Access denied',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return NotFoundException(
          'Resource not found',
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return ValidationException(
          message,
          statusCode: statusCode,
          data: data,
          fieldErrors: _extractFieldErrors(data),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'Server error. Please try again later.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return UnknownException(
          message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message'] ??
          data['error'] ??
          data['detail'] ??
          data['msg'];
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final Map<String, List<String>> errors = {};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        errors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        errors[key] = [value];
      }
    }

    return errors.isEmpty ? null : errors;
  }
}
