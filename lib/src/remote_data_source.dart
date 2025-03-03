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
  /// Parameters:
  /// - [baseURL]: Required base URL for all API requests
  /// - [authToken]: Optional authentication token for protected endpoints
  /// - [enableLogs]: Optional flag to enable/disable logging (default: true)
  /// - [client]: Optional HTTP client instance for custom configurations
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
  /// Parameters:
  /// - [method]: HTTP method (GET, POST, etc.)
  /// - [url]: Request URL
  /// - [body]: Optional request body
  void _logRequest(String method, String url, dynamic body) {
    if (enableLogs) {
      ApiLogger.info('REQUEST [$method] $url');
      if (body != null) ApiLogger.debug('Request Body: $body');
    }
  }

  /// Logs response details if logging is enabled.
  ///
  /// Parameters:
  /// - [response]: HTTP response object
  void _logResponse(http.Response response) {
    if (enableLogs) {
      ApiLogger.info(
          'RESPONSE [${response.statusCode}] ${response.request?.url.toString()}');
      ApiLogger.debug('Response Body: ${response.body}');
    }
  }

  /// Performs a GET request.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [queryParameters]: Optional query parameters
  ///
  /// Returns a Future that resolves to either a Map or List, depending on the response
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
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [body]: Optional request body
  /// - [customBaseURL]: Optional custom base URL for this request
  ///
  /// Returns a Future that resolves to the response data
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
    final uri = Uri.parse((customBaseURL ?? baseURL) + endPoint);

    _logRequest('POST', uri.toString(), body);

    try {
      final response = await _client.post(
        uri,
        body: jsonEncode(body),
        headers: _headers,
      );
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      ApiLogger.error('POST Request Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Performs a PUT request.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [body]: Request body
  ///
  /// Returns a Future that resolves to the response data
  Future<dynamic> put({
    required String endPoint,
    required Object body,
  }) async {
    final uri = Uri.parse(baseURL + endPoint);

    _logRequest('PUT', uri.toString(), body);

    try {
      final response = await _client.put(
        uri,
        body: jsonEncode(body),
        headers: _headers,
      );
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      ApiLogger.error('PUT Request Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Performs a DELETE request.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [body]: Optional request body
  ///
  /// Returns a Future that resolves to the response data
  Future<dynamic> delete({
    required String endPoint,
    Object? body,
  }) async {
    final uri = Uri.parse(baseURL + endPoint);

    _logRequest('DELETE', uri.toString(), body);

    try {
      final response = await _client.delete(
        uri,
        body: body != null ? jsonEncode(body) : null,
        headers: _headers,
      );
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      ApiLogger.error('DELETE Request Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Downloads a file from the server.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [body]: Optional request body
  /// - [customBaseURL]: Optional custom base URL
  ///
  /// Returns a Future that resolves to the file bytes
  Future<Uint8List> downloadFile({
    required String endPoint,
    Object? body,
    String? customBaseURL,
  }) async {
    final uri = Uri.parse((customBaseURL ?? baseURL) + endPoint);

    _logRequest('GET', uri.toString(), body);

    try {
      final response = await _client.get(uri, headers: _headers);
      _logResponse(response);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw BadRequestException(
          message: 'File download failed: ${response.statusCode}');
    } catch (e) {
      ApiLogger.error('File Download Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Uploads files to the server.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint
  /// - [fields]: Additional form fields
  /// - [files]: List of files to upload
  /// - [singleFile]: Whether to upload as single file
  ///
  /// Returns a Future that resolves to the response data
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
    final uri = Uri.parse(baseURL + endPoint);
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers);

    _logRequest('POST (Multipart)', uri.toString(), fields);

    try {
      if (files != null && files.isNotEmpty) {
        if (singleFile) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              files.first.bytes ?? [],
              filename: files.first.name,
            ),
          );
        } else {
          for (var file in files) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'files[]',
                file.bytes ?? [],
                filename: file.name,
              ),
            );
          }
        }
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      ApiLogger.error('File Upload Failed', e);
      throw NetworkException(message: e.toString());
    }
  }

  /// Handles the HTTP response and converts it to appropriate format.
  ///
  /// Parameters:
  /// - [response]: HTTP response object
  ///
  /// Returns the parsed response body
  /// Throws appropriate exceptions based on status code
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
