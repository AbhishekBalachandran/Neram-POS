/// Base class for all application-level exceptions.
sealed class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network-related failure (connection timeout, socket exception, DNS).
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
  });
}

/// HTTP API error response from server (4xx, 5xx).
class ApiException extends AppException {
  const ApiException({
    required super.message,
    required this.statusCode,
    super.code,
    this.responseData,
  });

  final int? statusCode;
  final dynamic responseData;
}

/// Authentication/Authorization failure (401 Unauthorized or expired session).
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session has expired or credentials are invalid',
    super.code = 'UNAUTHORIZED',
  });
}

/// Secure storage read/write failure.
class SecureStorageException extends AppException {
  const SecureStorageException({
    required super.message,
    super.code = 'SECURE_STORAGE_ERROR',
  });
}

/// General internal app exception.
class UnexpectedException extends AppException {
  const UnexpectedException({
    required super.message,
    super.code = 'UNEXPECTED_ERROR',
  });
}
