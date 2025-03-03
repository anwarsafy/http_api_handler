/// Base exception class for all API-related errors.
/// Provides common functionality for handling API exceptions with messages and status codes.
class ApiException implements Exception {
  /// A descriptive message explaining the error.
  final String message;

  /// The HTTP status code associated with the error (if applicable).
  final int? statusCode;

  /// Creates a new [ApiException] instance.
  ///
  /// [message] is required and provides error details.
  /// [statusCode] is optional and represents the HTTP status code.
  ///
  /// Example:
  /// ```dart
  /// throw ApiException(message: 'Invalid data', statusCode: 422);
  /// ```
  ApiException({required this.message, this.statusCode});

  /// Provides a string representation of the exception.
  ///
  /// Returns a formatted string containing the error message and status code.
  ///
  /// Example output: "ApiException: Invalid data (Status Code: 422)"
  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

/// Exception for network-related errors.
/// Used when there are connectivity issues or network failures.
///
/// Example usage:
/// ```dart
/// try {
///   await makeNetworkCall();
/// } catch (e) {
///   throw NetworkException(message: 'Failed to connect to server');
/// }
/// ```
class NetworkException extends ApiException {
  /// Creates a new [NetworkException] instance.
  ///
  /// [message] defaults to 'Network Error' if not provided.
  /// No status code is set as this is typically a client-side error.
  NetworkException({String message = 'Network Error'})
      : super(message: message);
}

/// Exception for authentication-related errors (HTTP 401).
/// Used when authentication fails or access token is invalid/expired.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 401) {
///   throw AuthenticationException(message: 'Invalid token');
/// }
/// ```
class AuthenticationException extends ApiException {
  /// Creates a new [AuthenticationException] instance.
  ///
  /// [message] defaults to 'Authentication Failed' if not provided.
  /// Status code is automatically set to 401 (Unauthorized).
  AuthenticationException({String message = 'Authentication Failed'})
      : super(message: message, statusCode: 401);
}

/// Exception for server-related errors (HTTP 500).
/// Used when the server encounters an error while processing the request.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 500) {
///   throw ServerException(message: 'Internal server error');
/// }
/// ```
class ServerException extends ApiException {
  /// Creates a new [ServerException] instance.
  ///
  /// [message] defaults to 'Server Error' if not provided.
  /// Status code is automatically set to 500 (Internal Server Error).
  ServerException({String message = 'Server Error'})
      : super(message: message, statusCode: 500);
}

/// Exception for bad request errors (HTTP 400).
/// Used when the request is malformed or contains invalid data.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 400) {
///   throw BadRequestException(message: 'Invalid parameters');
/// }
/// ```
class BadRequestException extends ApiException {
  /// Creates a new [BadRequestException] instance.
  ///
  /// [message] defaults to 'Bad Request' if not provided.
  /// Status code is automatically set to 400 (Bad Request).
  BadRequestException({String message = 'Bad Request'})
      : super(message: message, statusCode: 400);
}
