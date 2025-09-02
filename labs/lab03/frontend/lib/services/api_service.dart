// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  late final http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Базовый разбор ответа. Пока не используется в тестах, но пригодится.
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decoded);
    } else if (status >= 400 && status < 500) {
      throw ApiException('Client error ${response.statusCode}');
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error ${response.statusCode}');
    } else {
      throw ApiException('Unexpected status ${response.statusCode}');
    }
  }

  /* ---------------------- методы-заглушки ---------------------- */

  Future<List<Message>> getMessages() =>
      throw UnimplementedError('TODO: Implement getMessages');

  Future<Message> createMessage(CreateMessageRequest request) =>
      throw UnimplementedError('TODO: Implement createMessage');

  Future<Message> updateMessage(int id, UpdateMessageRequest request) =>
      throw UnimplementedError('TODO: Implement updateMessage');

  Future<void> deleteMessage(int id) =>
      throw UnimplementedError('TODO: Implement deleteMessage');

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) =>
      throw UnimplementedError('TODO: Implement getHTTPStatus');

  Future<Map<String, dynamic>> healthCheck() =>
      throw UnimplementedError('TODO: Implement healthCheck');
}

/* --------------------------- исключения --------------------------- */

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
