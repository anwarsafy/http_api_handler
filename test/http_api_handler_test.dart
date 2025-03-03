import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_api_handler/http_api_handler.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'http_api_handler_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiHandler Tests with Cat Facts API', () {
    late ApiHandler apiHandler;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      apiHandler = ApiHandler(
        baseURL: 'https://cat-fact.herokuapp.com', // Updated base URL
        authToken: 'test_token',
        enableLogs: false,
        client: mockHttpClient, // Pass the mocked client to ApiHandler
      );
    });

    test('GET /facts request success', () async {
      // Sample response data from the /facts endpoint
      final responseData = [
        {
          "_id": "591f98703b90f7150a19c138",
          "text": "Cats are the best pets.",
          "type": "cat",
          "user": {
            "_id": "591f98543b90f7150a19c137",
            "name": {"first": "John", "last": "Doe"}
          },
          "upvotes": 10,
          "userUpvoted": null
        },
        {
          "_id": "591f98703b90f7150a19c139",
          "text": "Cats can jump up to 6 times their height.",
          "type": "cat",
          "user": {
            "_id": "591f98543b90f7150a19c137",
            "name": {"first": "Jane", "last": "Doe"}
          },
          "upvotes": 15,
          "userUpvoted": null
        }
      ];

      // Mock the GET request to /facts
      when(mockHttpClient.get(
        Uri.parse('https://cat-fact.herokuapp.com/facts'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseData), // Simulate JSON response
            200, // Simulate successful status code
          ));

      // Call the GET method on ApiHandler
      final result = await apiHandler.get(endPoint: '/facts');

      // Verify the response matches the expected data
      expect(result, equals(responseData));
    });

    test('GET /facts request with server error throws ServerException',
        () async {
      // Simulate a server error response
      final errorResponse = {'message': 'Server Error'};

      when(mockHttpClient.get(
        Uri.parse('https://cat-fact.herokuapp.com/facts'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            500, // Simulate server error status code
          ));

      // Verify that the ApiHandler throws a ServerException
      expect(
        () => apiHandler.get(endPoint: '/facts'),
        throwsA(isA<ServerException>()),
      );
    });

    test('GET /facts request with network error throws NetworkException', () {
      // Simulate a network error
      when(mockHttpClient.get(
        Uri.parse('https://cat-fact.herokuapp.com/facts'),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));

      // Verify that the ApiHandler throws a NetworkException
      expect(
        () => apiHandler.get(endPoint: '/facts'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
