import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lab03_frontend/services/api_service.dart';
import 'package:lab03_frontend/models/message.dart';

// Integration tests that make real network requests to the backend
// These tests should be run separately from widget tests
void main() {
  group('Integration Tests (Real Network)', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    group('Backend Connectivity Tests', () {
      test('should connect to backend and get messages', () async {
        final messages = await apiService.getMessages();
        expect(messages, isA<List<Message>>());
        // Should not throw any CORS or network errors
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should perform health check', () async {
        final health = await apiService.healthCheck();
        expect(health, isA<Map<String, dynamic>>());
        expect(health['status'], equals('healthy'));
      }, timeout: const Timeout(Duration(seconds: 10)));
    });

    group('Message CRUD Tests', () {
      test('should create, read, update, and delete messages', () async {
        // Create
        final createRequest = CreateMessageRequest(
          username: 'integrationtest',
          content: 'Integration test message',
        );
        final createdMessage = await apiService.createMessage(createRequest);
        expect(createdMessage, isA<Message>());
        expect(createdMessage.username, equals('integrationtest'));
        expect(createdMessage.content, equals('Integration test message'));
        expect(createdMessage.id, isA<int>());
        expect(createdMessage.timestamp, isA<DateTime>());

        // Read
        final allMessages = await apiService.getMessages();
        final foundMessage =
            allMessages.firstWhere((m) => m.id == createdMessage.id);
        expect(foundMessage.content, equals('Integration test message'));

        // Update
        final updateRequest =
            UpdateMessageRequest(content: 'Updated integration test message');
        final updatedMessage =
            await apiService.updateMessage(createdMessage.id, updateRequest);
        expect(
            updatedMessage.content, equals('Updated integration test message'));

        // Delete
        await apiService.deleteMessage(createdMessage.id);

        // Verify deletion
        final messagesAfterDelete = await apiService.getMessages();
        expect(
            messagesAfterDelete.any((m) => m.id == createdMessage.id), isFalse);
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should handle multiple messages', () async {
        // Create multiple messages
        final messages = <Message>[];
        for (int i = 1; i <= 3; i++) {
          final request = CreateMessageRequest(
            username: 'multitest$i',
            content: 'Test message $i',
          );
          final message = await apiService.createMessage(request);
          messages.add(message);
        }

        // Verify all messages exist
        final allMessages = await apiService.getMessages();
        for (final message in messages) {
          expect(allMessages.any((m) => m.id == message.id), isTrue);
        }

        // Clean up
        for (final message in messages) {
          await apiService.deleteMessage(message.id);
        }
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('HTTP Status and Image Tests', () {
      test('should get HTTP status with working image URLs', () async {
        const testCodes = [200, 404, 500];

        for (final code in testCodes) {
          final statusResponse = await apiService.getHTTPStatus(code);
          expect(statusResponse, isA<HTTPStatusResponse>());
          expect(statusResponse.statusCode, equals(code));
          expect(statusResponse.imageUrl,
              contains('localhost:8080/api/cat/$code'));

          // Test that the image URL is accessible and returns an image
          final imageResponse =
              await http.get(Uri.parse(statusResponse.imageUrl));
          expect(imageResponse.statusCode, equals(200));
          expect(imageResponse.headers['content-type'], contains('image/'));
          expect(imageResponse.bodyBytes.length, greaterThan(0));
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should handle CORS for image requests', () async {
        final statusResponse = await apiService.getHTTPStatus(200);
        final imageUrl = statusResponse.imageUrl;

        // Test image request with CORS headers
        final imageResponse = await http.get(
          Uri.parse(imageUrl),
          headers: {
            'Origin': 'http://localhost:3000',
            'Accept': 'image/*',
          },
        );

        expect(imageResponse.statusCode, equals(200));
        expect(imageResponse.headers['access-control-allow-origin'],
            equals('http://localhost:3000'));
        expect(imageResponse.headers['content-type'], contains('image/'));
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should get different images for different status codes', () async {
        final status200 = await apiService.getHTTPStatus(200);
        final status404 = await apiService.getHTTPStatus(404);
        final status500 = await apiService.getHTTPStatus(500);

        // Should have different image URLs
        expect(status200.imageUrl, isNot(equals(status404.imageUrl)));
        expect(status200.imageUrl, isNot(equals(status500.imageUrl)));
        expect(status404.imageUrl, isNot(equals(status500.imageUrl)));

        // Should have different descriptions
        expect(status200.description, isNot(equals(status404.description)));
        expect(status200.description, isNot(equals(status500.description)));
      }, timeout: const Timeout(Duration(seconds: 20)));

      test('should handle edge case status codes', () async {
        const edgeCodes = [100, 418, 503];

        for (final code in edgeCodes) {
          final statusResponse = await apiService.getHTTPStatus(code);
          expect(statusResponse.statusCode, equals(code));
          expect(statusResponse.imageUrl,
              contains('localhost:8080/api/cat/$code'));

          // Verify image is accessible
          final imageResponse =
              await http.get(Uri.parse(statusResponse.imageUrl));
          expect(imageResponse.statusCode, equals(200));
        }
      }, timeout: const Timeout(Duration(seconds: 20)));
    });

    group('CORS Configuration Tests', () {
      test('should handle CORS headers correctly for API requests', () async {
        final response = await http.get(
          Uri.parse('http://localhost:8080/api/messages'),
          headers: {
            'Origin': 'http://localhost:3000',
            'Content-Type': 'application/json',
          },
        );

        expect(response.statusCode, equals(200));
        expect(response.headers['access-control-allow-origin'],
            equals('http://localhost:3000'));
        expect(
            response.headers['access-control-allow-methods'], contains('GET'));
        expect(response.headers['access-control-allow-headers'],
            contains('Content-Type'));
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should handle OPTIONS preflight request', () async {
        final response = await http.post(
          Uri.parse('http://localhost:8080/api/messages'),
          headers: {
            'Origin': 'http://localhost:3000',
            'Access-Control-Request-Method': 'POST',
            'Access-Control-Request-Headers': 'Content-Type',
          },
        );

        // The backend might handle this differently, so we check for either success or proper CORS headers
        expect(response.statusCode, isIn([200, 201, 400, 405]));
        if (response.statusCode == 200 || response.statusCode == 201) {
          expect(response.headers['access-control-allow-origin'],
              equals('http://localhost:3000'));
        }
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should handle CORS for PUT requests', () async {
        // First create a message
        final createRequest = CreateMessageRequest(
          username: 'cors_test',
          content: 'CORS test message',
        );
        final message = await apiService.createMessage(createRequest);

        // Test PUT with CORS headers
        final response = await http.put(
          Uri.parse('http://localhost:8080/api/messages/${message.id}'),
          headers: {
            'Origin': 'http://localhost:3000',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'content': 'Updated CORS test message'}),
        );

        expect(response.statusCode, equals(200));
        expect(response.headers['access-control-allow-origin'],
            equals('http://localhost:3000'));

        // Clean up
        await apiService.deleteMessage(message.id);
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should handle CORS for DELETE requests', () async {
        // First create a message
        final createRequest = CreateMessageRequest(
          username: 'cors_delete_test',
          content: 'CORS delete test message',
        );
        final message = await apiService.createMessage(createRequest);

        // Test DELETE with CORS headers
        final response = await http.delete(
          Uri.parse('http://localhost:8080/api/messages/${message.id}'),
          headers: {
            'Origin': 'http://localhost:3000',
          },
        );

        expect(response.statusCode, equals(204));
        expect(response.headers['access-control-allow-origin'],
            equals('http://localhost:3000'));
      }, timeout: const Timeout(Duration(seconds: 15)));
    });

    group('Error Handling Tests', () {
      test('should handle 404 errors gracefully', () async {
        expect(
            () async => await apiService.updateMessage(
                99999, UpdateMessageRequest(content: 'test')),
            throwsA(isA<ApiException>()));
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should handle invalid status codes', () async {
        expect(() async => await apiService.getHTTPStatus(999),
            throwsA(isA<ApiException>()));
      }, timeout: const Timeout(Duration(seconds: 10)));
    });
  });
}
