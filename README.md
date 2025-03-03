# HTTP API Handler

[![pub package](https://img.shields.io/pub/v/http_api_handler.svg)](https://pub.dev/packages/http_api_handler)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible Flutter package for handling HTTP API requests with built-in logging, error handling, and file operations. Designed to simplify API integration in Flutter applications.

## Features 🚀

- ✨ Easy-to-use HTTP methods (GET, POST, PUT, DELETE)
- 📁 File upload support (single and multiple files)
- ⬇️ File download capability
- 📝 Built-in logging system
- ❌ Comprehensive error handling
- 🔐 Authentication token support
- 🔍 Query parameters support
- 🎯 Custom base URL support
- 🧪 Fully tested

## Installation 💻

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  http_api_handler: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage 📱

### Initialize the API Handler

```dart
final api = ApiHandler(
  baseURL: 'https://api.example.com',  // Your API base URL
  authToken: 'your_auth_token',        // Optional: JWT or other auth token
  enableLogs: true,                    // Enable/disable logging
  additionalHeaders: {                 // Optional: Additional headers
    'Custom-Header': 'Value',
  },
);
```

### Basic HTTP Requests

#### GET Request

```dart
// Simple GET request
try {
  final response = await api.get(
    endPoint: '/users',
  );
  print('Users: $response');
} catch (e) {
  print('Error: $e');
}

// GET request with query parameters
try {
  final response = await api.get(
    endPoint: '/users',
    queryParameters: {
      'page': '1',
      'limit': '10',
      'sort': 'desc',
    },
  );
  print('Filtered Users: $response');
} catch (e) {
  print('Error: $e');
}
```

#### POST Request

```dart
try {
  final response = await api.post(
    endPoint: '/users',
    body: {
      'name': 'John Doe',
      'email': 'john@example.com',
      'age': 30,
    },
  );
  print('Created User: $response');
} catch (e) {
  print('Error: $e');
}
```

#### PUT Request

```dart
try {
  final response = await api.put(
    endPoint: '/users/123',
    body: {
      'name': 'Updated Name',
      'email': 'updated@example.com',
    },
  );
  print('Updated User: $response');
} catch (e) {
  print('Error: $e');
}
```

#### DELETE Request

```dart
try {
  final response = await api.delete(
    endPoint: '/users/123',
  );
  print('Deleted User: $response');
} catch (e) {
  print('Error: $e');
}
```

### File Operations

#### Upload Single File

```dart
try {
  final response = await api.uploadFiles(
    endPoint: '/upload',
    files: [yourFile],  // PlatformFile from file_picker
    singleFile: true,
    fields: {           // Optional additional fields
      'type': 'profile',
      'userId': '123',
    },
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload Progress: $progress%');
    },
  );
  print('Upload Response: $response');
} catch (e) {
  print('Upload Error: $e');
}
```

#### Upload Multiple Files

```dart
try {
  final response = await api.uploadFiles(
    endPoint: '/upload/multiple',
    files: yourFiles,  // List<PlatformFile> from file_picker
    singleFile: false,
    fields: {'type': 'gallery'},
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload Progress: $progress%');
    },
  );
  print('Multiple Upload Response: $response');
} catch (e) {
  print('Upload Error: $e');
}
```

#### Download File

```dart
try {
  final fileBytes = await api.downloadFile(
    endPoint: '/download',
    body: {'fileId': '123'},
  );
  // Handle the downloaded file bytes
  // Example: Save to file system
  await File('downloaded_file.pdf').writeAsBytes(fileBytes);
} catch (e) {
  print('Download Error: $e');
}
```

### Error Handling

The package provides specific exceptions for different scenarios:

```dart
try {
  final response = await api.get(endPoint: '/protected-resource');
} on AuthenticationException catch (e) {
  // Handle 401 Unauthorized
  print('Authentication Error: ${e.message}');
  // Example: Redirect to login
} on BadRequestException catch (e) {
  // Handle 400 Bad Request
  print('Bad Request: ${e.message}');
  // Example: Show validation errors
} on ServerException catch (e) {
  // Handle 500 Server Error
  print('Server Error: ${e.message}');
  // Example: Show server error message
} on NetworkException catch (e) {
  // Handle network/connectivity issues
  print('Network Error: ${e.message}');
  // Example: Show offline message
} on ApiException catch (e) {
  // Handle other API errors
  print('API Error: ${e.message} (${e.statusCode})');
  // Example: Show generic error message
}
```

### Logging

The package includes comprehensive logging that can be enabled/disabled:

```dart
// Enable logging (default: true)
final api = ApiHandler(
  baseURL: 'https://api.example.com',
  enableLogs: true,
);

// Logs will include:
// ✓ Request URL
// ✓ Request Method
// ✓ Request Headers
// ✓ Request Body
// ✓ Response Status Code
// ✓ Response Body
// ✓ Error Details (if any)
```

### Custom Base URL

You can use a different base URL for specific requests:

```dart
final response = await api.post(
  endPoint: '/special-endpoint',
  body: {'data': 'value'},
  customBaseURL: 'https://another-api.com',
);
```

## Error Types 🚨

| Exception Type | Description | Status Code |
|----------------|-------------|-------------|
| ApiException | Base exception class | Any |
| AuthenticationException | Authentication failed | 401 |
| BadRequestException | Invalid request | 400 |
| ServerException | Server error | 500 |
| NetworkException | Network/connectivity issues | N/A |

## Contributing 🤝

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Testing 🧪

The package includes comprehensive tests. Run them with:

```bash
flutter test
```

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Author ✍️

Mahmoud Aziz
- GitHub: @mahmoudazizorignal
- LinkedIn: @mahmoudazizorignal

## Support ❤️

If you find this package helpful, please give it a ⭐️ on GitHub!

## Changelog 📝

See CHANGELOG.md for all changes.

## Issues and Feedback 💭

Please file specific issues, bugs, or feature requests in our issue tracker.

## FAQ 📚

**Q: Can I use this package with DIO?**

A: Currently, the package uses the http package. DIO support might be added in future versions.

**Q: Is this package null-safe?**

A: Yes, this package is null-safe and requires Dart SDK 2.12.0 or later.

**Q: Does it support file upload progress?**

A: Yes, file upload progress can be monitored using the onProgress callback in file upload methods.

**Q: Can I use custom error handling?**

A: Yes, you can catch the base ApiException and implement your own error handling logic.

**Q: Is it compatible with Flutter Web?**

A: Yes, this package is fully compatible with Flutter Web and all other Flutter platforms.

**Q: Can I add custom headers?**

A: Yes, you can add custom headers through the additionalHeaders parameter when initializing the ApiHandler.

**Q: How do I handle refresh tokens?**

A: You can implement a custom interceptor by extending the ApiHandler class and overriding the necessary methods.