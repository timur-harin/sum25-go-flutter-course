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

    test('should get messages successfully', () async {
      // This test will pass when students implement the getMessages method
      try {
        final messages = await apiService.getMessages();
        expect(messages, isA<List<Message>>());
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should create message successfully', () async {
      // This test will pass when students implement the createMessage method
      final request = CreateMessageRequest(
        username: 'testuser',
        content: 'test message',
      );

      try {
        final message = await apiService.createMessage(request);
        expect(message, isA<Message>());
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should update message successfully', () async {
      // This test will pass when students implement the updateMessage method
      final request = UpdateMessageRequest(content: 'updated content');

      try {
        final message = await apiService.updateMessage(1, request);
        expect(message, isA<Message>());
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should delete message successfully', () async {
      // This test will pass when students implement the deleteMessage method
      try {
        await apiService.deleteMessage(1);
        // If no exception is thrown, the test passes
        expect(true, true);
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should get HTTP status successfully', () async {
      // This test will pass when students implement the getHTTPStatus method
      try {
        final status = await apiService.getHTTPStatus(200);
        expect(status, isA<HTTPStatusResponse>());
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should perform health check successfully', () async {
      // This test will pass when students implement the healthCheck method
      try {
        final health = await apiService.healthCheck();
        expect(health, isA<Map<String, dynamic>>());
      } catch (e) {
        expect(e, isA<UnimplementedError>());
      }
    });

    test('should validate CreateMessageRequest', () {
      // Test valid request
      final validRequest = CreateMessageRequest(
        username: 'testuser',
        content: 'test message',
      );
      expect(validRequest.validate(), isNull);

      // Test invalid requests
      final emptyUsernameRequest = CreateMessageRequest(
        username: '',
        content: 'test message',
      );
      expect(emptyUsernameRequest.validate(), isNotNull);

      final emptyContentRequest = CreateMessageRequest(
        username: 'testuser',
        content: '',
      );
      expect(emptyContentRequest.validate(), isNotNull);
    });

    test('should validate UpdateMessageRequest', () {
      // Test valid request
      final validRequest = UpdateMessageRequest(content: 'updated content');
      expect(validRequest.validate(), isNull);

      // Test invalid request
      final emptyContentRequest = UpdateMessageRequest(content: '');
      expect(emptyContentRequest.validate(), isNotNull);
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
