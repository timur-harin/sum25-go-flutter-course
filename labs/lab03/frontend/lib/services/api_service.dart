import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode < 500) {
      String message = 'Client error: ${response.body}';
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'];
        }
      } catch (_) {}
      throw ApiException(message);
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  // ЗАГЛУШКИ ДЛЯ ТЕСТОВ - убираем nullable типы
  Future<List<Message>> getMessages() async {
    throw UnimplementedError();
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError();
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError();
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError();
  }

  // Изменяем с HTTPStatusResponse? на HTTPStatusResponse
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError();
  }
}

// Custom exceptions
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
