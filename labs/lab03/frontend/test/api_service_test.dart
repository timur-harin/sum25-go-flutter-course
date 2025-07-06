import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:lab03_frontend/services/api_service.dart';
import 'package:lab03_frontend/models/message.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    // Helper function to create ApiService with mock client
    ApiService _createApiServiceWithMockClient(MockClient mockClient) {
      return ApiService(client: mockClient);
    }

    // MOCK TESTS
    group('Mock Tests', () {
      test('should get messages successfully', () async {
        // Mock client that returns a successful response
        final mockClient = MockClient((request) async {
          if (request.url.toString() == 'http://localhost:8080/api/messages' &&
              request.method == 'GET') {
            final response = {
              'success': true,
              'data': [
                {
                  'id': 1,
                  'username': 'testuser',
                  'content': 'test message',
                  'timestamp': '2024-01-01T00:00:00.000Z'
                }
              ]
            };
            return http.Response(jsonEncode(response), 200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final messages = await apiService.getMessages();

        expect(messages, isA<List<Message>>());
        expect(messages.length, equals(1));
        expect(messages.first.username, equals('testuser'));
        expect(messages.first.content, equals('test message'));
      });

      test('should create message successfully', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString() == 'http://localhost:8080/api/messages' &&
              request.method == 'POST') {
            final response = {
              'success': true,
              'data': {
                'id': 2,
                'username': 'newuser',
                'content': 'new message',
                'timestamp': '2024-01-01T00:00:00.000Z'
              }
            };
            return http.Response(jsonEncode(response), 201);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final request =
            CreateMessageRequest(username: 'newuser', content: 'new message');
        final message = await apiService.createMessage(request);

        expect(message.username, equals('newuser'));
        expect(message.content, equals('new message'));
      });

      test('should update message successfully', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString() ==
                  'http://localhost:8080/api/messages/1' &&
              request.method == 'PUT') {
            final response = {
              'success': true,
              'data': {
                'id': 1,
                'username': 'testuser',
                'content': 'updated message',
                'timestamp': '2024-01-01T00:00:00.000Z'
              }
            };
            return http.Response(jsonEncode(response), 200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final request = UpdateMessageRequest(content: 'updated message');
        final message = await apiService.updateMessage(1, request);

        expect(message.content, equals('updated message'));
      });

      test('should delete message successfully', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString() ==
                  'http://localhost:8080/api/messages/1' &&
              request.method == 'DELETE') {
            return http.Response('', 204);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        await apiService.deleteMessage(1);
        // Should not throw an exception
      });

      test('should get HTTP status successfully', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString().contains('/api/status/200')) {
            return http.Response(
                '{"success":true,"data":{"status_code":200,"description":"OK","image_url":"http://localhost:8080/api/cat/200"}}',
                200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final status = await apiService.getHTTPStatus(200);

        expect(status.statusCode, equals(200));
        expect(status.description, equals('OK'));
        expect(status.imageUrl, contains('/api/cat/200'));
      });

      test('should perform health check successfully', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString() == 'http://localhost:8080/api/health' &&
              request.method == 'GET') {
            final response = {
              'status': 'healthy',
              'timestamp': '2024-01-01T00:00:00Z',
              'version': '1.0.0'
            };
            return http.Response(jsonEncode(response), 200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final health = await apiService.healthCheck();

        expect(health['status'], equals('healthy'));
        expect(health['version'], equals('1.0.0'));
      });

      test('should handle network errors', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Network error');
        });

        final apiService = _createApiServiceWithMockClient(mockClient);

        expect(() => apiService.getMessages(), throwsA(isA<ApiException>()));
      });

      test('should handle 404 errors for update', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);
        final request = UpdateMessageRequest(content: 'test');

        expect(() => apiService.updateMessage(999, request),
            throwsA(isA<ApiException>()));
      });

      test('should handle 404 errors for delete', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final apiService = _createApiServiceWithMockClient(mockClient);

        expect(
            () => apiService.deleteMessage(999), throwsA(isA<ApiException>()));
      });

      test('should validate CreateMessageRequest', () {
        final validRequest =
            CreateMessageRequest(username: 'test', content: 'test');
        expect(validRequest.validate(), isNull);

        final invalidRequest = CreateMessageRequest(username: '', content: '');
        expect(invalidRequest.validate(), isNotNull);
      });

      test('should validate UpdateMessageRequest', () {
        final validRequest = UpdateMessageRequest(content: 'test');
        expect(validRequest.validate(), isNull);

        final invalidRequest = UpdateMessageRequest(content: '');
        expect(invalidRequest.validate(), isNotNull);
      });
    });

    // HTTP STATUS TESTS
    group('HTTP Status Tests', () {
      test('should have valid HTTP status codes', () {
        // Test basic HTTP status code ranges
        const informational = [100, 101, 102];
        const successful = [200, 201, 202, 204];
        const redirection = [300, 301, 302, 304];
        const clientError = [400, 401, 403, 404, 418];
        const serverError = [500, 501, 502, 503, 504];

        final allCodes = [
          ...informational,
          ...successful,
          ...redirection,
          ...clientError,
          ...serverError,
        ];

        // Verify all codes are valid HTTP status codes
        for (final code in allCodes) {
          expect(code, isA<int>());
          expect(code, greaterThanOrEqualTo(100));
          expect(code, lessThan(600));
        }
      });

      test('should have proper status code descriptions', () {
        final statusCodes = {
          200: 'OK',
          404: 'Not Found',
          500: 'Internal Server Error',
          418: "I'm a teapot",
          503: 'Service Unavailable',
        };

        for (final entry in statusCodes.entries) {
          expect(entry.value, isNotEmpty);
          expect(entry.value, isA<String>());
        }
      });

      test('should get HTTP status for valid codes', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString().contains('/api/status/200')) {
            return http.Response(
                '{"success":true,"data":{"status_code":200,"description":"OK","image_url":"http://localhost:8080/api/cat/200"}}',
                200);
          }
          if (request.url.toString().contains('/api/status/404')) {
            return http.Response(
                '{"success":true,"data":{"status_code":404,"description":"Not Found","image_url":"http://localhost:8080/api/cat/404"}}',
                200);
          }
          if (request.url.toString().contains('/api/status/500')) {
            return http.Response(
                '{"success":true,"data":{"status_code":500,"description":"Internal Server Error","image_url":"http://localhost:8080/api/cat/500"}}',
                200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = ApiService(client: mockClient);

        // Test 200 OK
        final status200 = await apiService.getHTTPStatus(200);
        expect(status200.statusCode, equals(200));
        expect(status200.description, equals('OK'));
        expect(status200.imageUrl, contains('/api/cat/200'));

        // Test 404 Not Found
        final status404 = await apiService.getHTTPStatus(404);
        expect(status404.statusCode, equals(404));
        expect(status404.description, equals('Not Found'));
        expect(status404.imageUrl, contains('/api/cat/404'));

        // Test 500 Internal Server Error
        final status500 = await apiService.getHTTPStatus(500);
        expect(status500.statusCode, equals(500));
        expect(status500.description, equals('Internal Server Error'));
        expect(status500.imageUrl, contains('/api/cat/500'));

        apiService.dispose();
      });

      test('should handle invalid status codes', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
              '{"success":false,"error":"Invalid status code"}', 400);
        });

        final apiService = ApiService(client: mockClient);

        expect(
          () => apiService.getHTTPStatus(999),
          throwsA(isA<ApiException>()),
        );

        apiService.dispose();
      });

      test('should handle network errors gracefully', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Network error');
        });

        final apiService = ApiService(client: mockClient);

        expect(
          () => apiService.getHTTPStatus(200),
          throwsA(isA<ApiException>()),
        );

        apiService.dispose();
      });

      test('should validate status code ranges', () async {
        // Invalid status codes should throw validation error
        expect(
            () => ApiService().getHTTPStatus(99), throwsA(isA<ApiException>()));
        expect(() => ApiService().getHTTPStatus(600),
            throwsA(isA<ApiException>()));
        expect(
            () => ApiService().getHTTPStatus(-1), throwsA(isA<ApiException>()));

        // Valid status codes should return a Future (may fail with network error, but not validation)
        expect(ApiService().getHTTPStatus(100), completes);
        expect(ApiService().getHTTPStatus(200), completes);
        expect(ApiService().getHTTPStatus(404), completes);
        expect(ApiService().getHTTPStatus(500), completes);
        expect(ApiService().getHTTPStatus(599), completes);
      });

      test('should get HTTP status for multiple codes', () async {
        final mockClient = MockClient((request) async {
          if (request.url.toString().contains('/api/status/200')) {
            return http.Response(
                '{"success":true,"data":{"status_code":200,"description":"OK","image_url":"http://localhost:8080/api/cat/200"}}',
                200);
          }
          if (request.url.toString().contains('/api/status/404')) {
            return http.Response(
                '{"success":true,"data":{"status_code":404,"description":"Not Found","image_url":"http://localhost:8080/api/cat/404"}}',
                200);
          }
          if (request.url.toString().contains('/api/status/500')) {
            return http.Response(
                '{"success":true,"data":{"status_code":500,"description":"Internal Server Error","image_url":"http://localhost:8080/api/cat/500"}}',
                200);
          }
          return http.Response('Not Found', 404);
        });

        final apiService = ApiService(client: mockClient);

        // Test various status codes
        final statusCodes = [200, 404, 500];
        for (final code in statusCodes) {
          final status = await apiService.getHTTPStatus(code);
          expect(status.statusCode, equals(code));
          expect(status.description, isNotEmpty);
          expect(status.imageUrl, contains('/api/cat/$code'));
        }

        apiService.dispose();
      });

      test('should handle invalid status codes gracefully', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
              '{"success":false,"error":"Invalid status code"}', 400);
        });

        final apiService = ApiService(client: mockClient);

        expect(
          () => apiService.getHTTPStatus(999),
          throwsA(isA<ApiException>()),
        );

        apiService.dispose();
      });
    });
  });

  group('Exception Tests', () {
    test('should create ApiException correctly', () {
      final exception = ApiException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('Test error'));
    });

    test('should create NetworkException correctly', () {
      final exception = NetworkException('Network error');
      expect(exception.message, equals('Network error'));
      expect(exception, isA<ApiException>());
    });

    test('should create ServerException correctly', () {
      final exception = ServerException('Server error');
      expect(exception.message, equals('Server error'));
      expect(exception, isA<ApiException>());
    });

    test('should create ValidationException correctly', () {
      final exception = ValidationException('Validation error');
      expect(exception.message, equals('Validation error'));
      expect(exception, isA<ApiException>());
    });
  });
}
