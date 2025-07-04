import 'dart:convert';
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

  Future<T> _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode <= 299) {
      final decoded = json.decode(body);
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode <= 499) {
      String message;
      try {
        final decoded = json.decode(body);
        message = decoded['error'] ?? 'Client error';
      } catch (_) {
        message = 'Client error';
      }
      throw ApiException(message);
    } else if (statusCode >= 500 && statusCode <= 599) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected status code: $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    throw UnimplementedError('TODO: Implement getMessages');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement createMessage');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError('TODO: Implement getHTTPStatus');
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('TODO: Implement healthCheck');
  }
}

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
