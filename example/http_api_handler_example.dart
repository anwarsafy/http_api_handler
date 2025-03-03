import 'package:flutter/cupertino.dart';
import 'package:http_api_handler/http_api_handler.dart';

/// Example implementation of the HTTP API Handler package
/// Demonstrates basic usage including GET, POST, and file upload operations
/// with comprehensive error handling
void main() async {
  /// Initialize the API handler with configuration
  /// [baseURL]: The base URL for all API requests
  /// [authToken]: Authentication token for protected endpoints
  /// [enableLogs]: Enable detailed request/response logging
  final api = ApiHandler(
    baseURL: 'https://api.example.com',
    authToken: 'your_auth_token',
    enableLogs: true,
  );

  try {
    /// Perform a GET request to fetch users
    /// [endPoint]: The specific endpoint to call ('/users')
    /// [queryParameters]: Optional query parameters for filtering/pagination
    /// Returns: JSON response containing user data
    final users = await api.get(
      endPoint: '/users',
      queryParameters: {'page': '1'},
    );
    debugPrint('Users: $users');

    /// Perform a POST request to create a new user
    /// [endPoint]: The endpoint for user creation
    /// [body]: Request body containing user data
    /// Returns: JSON response containing created user data
    final newUser = await api.post(
      endPoint: '/users',
      body: {
        'name': 'John Doe',
        'email': 'john@example.com',
      },
    );
    debugPrint('New User: $newUser');

    /// Upload files to the server
    /// [endPoint]: File upload endpoint
    /// [fields]: Additional form fields to send with the files
    /// [files]: List of files to upload (PlatformFile objects)
    /// Returns: JSON response containing upload result
    final uploadResult = await api.uploadFiles(
      endPoint: '/upload',
      fields: {'type': 'profile'},
      files: [], // Add your PlatformFile objects here
    );
    debugPrint('Upload Result: $uploadResult');
  }

  /// Handle authentication errors (401)
  /// Typically occurs when the auth token is invalid or expired
  on AuthenticationException catch (e) {
    debugPrint('Authentication Error: ${e.message}');
  }

  /// Handle bad request errors (400)
  /// Occurs when the request is malformed or validation fails
  on BadRequestException catch (e) {
    debugPrint('Bad Request: ${e.message}');
  }

  /// Handle network connectivity errors
  /// Occurs when there's no internet connection or network issues
  on NetworkException catch (e) {
    debugPrint('Network Error: ${e.message}');
  }

  /// Handle general API errors
  /// Base exception class for all API-related errors
  on ApiException catch (e) {
    debugPrint('API Error: ${e.message}');
  }

  /// Handle unexpected errors
  /// Catches any other errors that might occur
  catch (e) {
    debugPrint('Unexpected Error: $e');
  }
}

/// Example response structure for GET /users
/// ```json
/// {
///   "users": [
///     {
///       "id": "1",
///       "name": "John Doe",
///       "email": "john@example.com"
///     }
///   ],
///   "page": 1,
///   "total": 10
/// }
/// ```

/// Example response structure for POST /users
/// ```json
/// {
///   "id": "1",
///   "name": "John Doe",
///   "email": "john@example.com",
///   "created_at": "2023-01-01T00:00:00Z"
/// }
/// ```

/// Example response structure for POST /upload
/// ```json
/// {
///   "success": true,
///   "file_url": "https://example.com/uploads/file.jpg",
///   "file_type": "profile",
///   "uploaded_at": "2023-01-01T00:00:00Z"
/// }
/// ```

/// Error Response Structure
/// ```json
/// {
///   "error": true,
///   "message": "Error description",
///   "code": "ERROR_CODE",
///   "status": 400
/// }
/// ```
