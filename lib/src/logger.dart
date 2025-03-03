import 'package:logger/logger.dart';

/// A utility class for handling application logging with different log levels
/// and formatted output. Uses the 'logger' package for advanced logging features.
///
/// Provides static methods for logging different types of messages:
/// - Info: General information
/// - Error: Error messages with stack traces
/// - Debug: Debug information
/// - Warning: Warning messages
class ApiLogger {
  /// Private logger instance configured with custom formatting options.
  ///
  /// Uses [PrettyPrinter] for formatted output with the following settings:
  /// - No method count for regular logs
  /// - 8 methods shown in error stack traces
  /// - 120 characters line length
  /// - Colored output enabled
  /// - Emoji support enabled
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if error occurs
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
    ),
  );

  /// Logs an informational message.
  ///
  /// Use this for general information that is useful for tracking
  /// application flow.
  ///
  /// Example:
  /// ```dart
  /// ApiLogger.info('Request started for endpoint: /users');
  /// ```
  ///
  /// [message] The information message to be logged
  static void info(String message) {
    _logger.i(message);
  }

  /// Logs an error message with optional error object and stack trace.
  ///
  /// Use this for logging errors and exceptions with their details.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   // Some code that might throw
  /// } catch (e, stackTrace) {
  ///   ApiLogger.error('Failed to fetch data', e, stackTrace);
  /// }
  /// ```
  ///
  /// [message] The error message to be logged
  /// [error] Optional error object
  /// [stackTrace] Optional stack trace
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a debug message.
  ///
  /// Use this for detailed information that is useful for debugging.
  /// These messages should typically be more verbose than info messages.
  ///
  /// Example:
  /// ```dart
  /// ApiLogger.debug('Request parameters: $parameters');
  /// ```
  ///
  /// [message] The debug message to be logged
  static void debug(String message) {
    _logger.d(message);
  }

  /// Logs a warning message.
  ///
  /// Use this for potentially harmful situations that don't qualify
  /// as errors but should be noted.
  ///
  /// Example:
  /// ```dart
  /// ApiLogger.warning('API rate limit approaching threshold');
  /// ```
  ///
  /// [message] The warning message to be logged
  static void warning(String message) {
    _logger.w(message);
  }
}

/// Usage Examples:
///
/// 1. Logging API Request:
/// ```dart
/// ApiLogger.info('Starting API request to: $endpoint');
/// ApiLogger.debug('Request Headers: $headers');
/// ```
///
/// 2. Logging API Response:
/// ```dart
/// ApiLogger.info('Received response with status: ${response.statusCode}');
/// ApiLogger.debug('Response body: ${response.body}');
/// ```
///
/// 3. Logging Errors:
/// ```dart
/// try {
///   await apiCall();
/// } catch (e, stackTrace) {
///   ApiLogger.error('API call failed', e, stackTrace);
/// }
/// ```
///
/// 4. Logging Warnings:
/// ```dart
/// if (responseTime > threshold) {
///   ApiLogger.warning('API response time exceeded threshold');
/// }
/// ```
///
/// Log Level Usage Guidelines:
/// - info: General operational messages
/// - error: Application errors and exceptions
/// - debug: Detailed information for debugging
/// - warning: Potentially harmful situations
