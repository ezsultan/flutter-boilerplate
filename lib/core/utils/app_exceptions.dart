/// Custom application exceptions mapped from HTTP errors.
///
/// Why this exists:
/// - Maps HTTP status codes to meaningful, typed exceptions.
/// - The UI layer can catch these specific exceptions to show appropriate messages.
/// - In a backend project, this is like your custom error classes or exception filters.
///
/// Usage:
/// - Datasources throw these exceptions when API calls fail.
/// - Providers catch them and update UI state accordingly.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

/// Exception for 401 Unauthorized errors.
///
/// Triggers token refresh or logout flow.
class UnauthorizedException extends AppException {
  const UnauthorizedException({String? message})
      : super(
          message: message ?? 'Session expired. Please login again.',
          statusCode: 401,
          code: 'UNAUTHORIZED',
        );
}

/// Exception for 403 Forbidden errors.
class ForbiddenException extends AppException {
  const ForbiddenException({String? message})
      : super(
          message: message ?? 'You do not have permission to access this resource.',
          statusCode: 403,
          code: 'FORBIDDEN',
        );
}

/// Exception for 404 Not Found errors.
class NotFoundException extends AppException {
  const NotFoundException({String? message})
      : super(
          message: message ?? 'The requested resource was not found.',
          statusCode: 404,
          code: 'NOT_FOUND',
        );
}

/// Exception for 500 Internal Server Error.
class ServerException extends AppException {
  const ServerException({String? message})
      : super(
          message: message ?? 'Internal server error. Please try again later.',
          statusCode: 500,
          code: 'SERVER_ERROR',
        );
}

/// Exception for request timeouts.
class TimeoutException extends AppException {
  const TimeoutException({String? message})
      : super(
          message: message ?? 'Request timed out. Please check your connection.',
          code: 'TIMEOUT',
        );
}

/// Exception for no internet connectivity.
class NetworkException extends AppException {
  const NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection. Please check your network.',
          code: 'NETWORK_ERROR',
        );
}

/// Exception for unknown/unexpected errors.
class UnknownException extends AppException {
  const UnknownException({String? message})
      : super(
          message: message ?? 'An unexpected error occurred.',
          code: 'UNKNOWN',
        );
}
