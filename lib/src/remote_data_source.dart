import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'exceptions.dart';
import 'logger.dart';

/// A handler class for making HTTP API requests with built-in logging and error handling.
/// Supports various HTTP methods, file uploads, and downloads.
class ApiHandler {
  /// Base URL for all API requests
  final String baseURL;

  /// Authentication token for protected endpoints
  final String? authToken;

  /// Flag to enable/disable request/response logging
  final bool enableLogs;

  /// HTTP client instance for making requests
  final http.Client _client;

  /// Creates a new [ApiHandler] instance.
  ///
  /// [baseURL] is required and should be the base URL for all API requests.
  /// [authToken] is optional and used for authenticated requests.
  /// [enableLogs] determines if request/response logging is enabled (default: true).
  /// [client] optional HTTP client instance for custom configurations.
  ApiHandler({
    required this.baseURL,
    this.authToken,
    this.enableLogs = true,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Default headers for all requests.
  /// Includes Content-Type and optional Authorization header.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  /// Logs request details if logging is enabled.
  ///
  /// [method] HTTP method (GET, POST, etc.)
  /// [url] Request URL
  /// [body] Request body (optional)
  void _logRequest(String method, String url, dynamic body) {
    if (enableLogs) {
      ApiLogger.info('REQUEST [$method] $url');
      if (body != null) ApiLogger.debug('Request Body: $body');
    }
  }

  /// Logs response details if logging is enabled.
  ///
  /// [response] HTTP response object
  void _logResponse(http.Response response) {
    if (enableLogs) {
      ApiLogger.info(
          'RESPONSE [${response.statusCode}] ${response.request?.url.toString()}');
      ApiLogger.debug('Response Body: ${response.body}');
    }
  }

  /// Performs a GET request.
  ///
  /// [endPoint] The API endpoint
  /// [queryParameters] Optional query parameters
  ///
  /// Returns the response data as Map<String, dynamic> or List
  ///
  /// Example:
  /// ```dart
  /// final response = await api.get(
  ///   endPoint: '/users',
  ///   queryParameters: {'page': '1'},
  /// );
  /// ```
  Future<dynamic> get({
    required String endPoint,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(baseURL + endPoint).replace(
      queryParameters: queryParameters,
    );

    _logRequest('GET', uri.toString(), null);

    try {
      final response = await _client.get(uri, headers: _headers);
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      ApiLogger.error('GET Request Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Performs a POST request.
  ///
  /// [endPoint] The API endpoint
  /// [body] Request body (optional)
  /// [customBaseURL] Optional custom base URL for this request
  ///
  /// Returns the response data
  ///
  /// Example:
  /// ```dart
  /// final response = await api.post(
  ///   endPoint: '/users',
  ///   body: {'name': 'John'},
  /// );
  /// ```
  Future<dynamic> post({
    required String endPoint,
    Object? body,
    String? customBaseURL,
  }) async {
    // ... (similar documentation for other methods)
  }

  /// Performs a PUT request.
  ///
  /// [endPoint] The API endpoint
  /// [body] Request body
  Future<dynamic> put({
    required String endPoint,
    required Object body,
  }) async {
    // ... (documentation)
  }

  /// Performs a DELETE request.
  ///
  /// [endPoint] The API endpoint
  /// [body] Request body (optional)
  Future<dynamic> delete({
    required String endPoint,
    Object? body,
  }) async {
    // ... (documentation)
  }

  /// Downloads a file from the server.
  ///
  /// [endPoint] The API endpoint
  /// [body] Request body (optional)
  /// [customBaseURL] Optional custom base URL
  ///
  /// Returns the file as Uint8List
  Future<Uint8List> downloadFile({
    required String endPoint,
    Object? body,
    String? customBaseURL,
  }) async {
    return _client
        .get(
      Uri.parse(customBaseURL ?? baseURL + endPoint),
      headers: _headers,
    )
        .then((response) {
      _logResponse(response);
      return response.bodyBytes;
    }).catchError((e) {
      ApiLogger.error('File Download Failed', e);
      throw NetworkException(message: e.toString());
    });
  }

  /// Uploads files to the server.
  ///
  /// [endPoint] The API endpoint
  /// [fields] Additional form fields
  /// [files] List of files to upload
  /// [singleFile] Whether to upload as single file
  ///
  /// Example:
  /// ```dart
  /// final response = await api.uploadFiles(
  ///   endPoint: '/upload',
  ///   fields: {'type': 'profile'},
  ///   files: [file],
  ///   singleFile: true,
  /// );
  /// ```
  Future<dynamic> uploadFiles({
    required String endPoint,
    Map<String, String>? fields,
    List<PlatformFile>? files,
    bool singleFile = false,
  }) async {
    // ... (documentation)
  }

  /// Handles the HTTP response and converts it to appropriate format.
  ///
  /// [response] HTTP response object
  ///
  /// Throws appropriate exceptions based on status code
  /// Returns parsed response body
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        if (body is List) return body;
        if (body is Map<String, dynamic>) return body;
        throw const FormatException('Invalid response format');
      case 400:
        throw BadRequestException(message: body['message'] ?? 'Bad Request');
      case 401:
        throw AuthenticationException(
            message: body['message'] ?? 'Authentication Failed');
      case 500:
        throw ServerException(message: body['message'] ?? 'Server Error');
      default:
        throw ApiException(
          message: body['message'] ?? 'Unknown Error',
          statusCode: response.statusCode,
        );
    }
  }
}
