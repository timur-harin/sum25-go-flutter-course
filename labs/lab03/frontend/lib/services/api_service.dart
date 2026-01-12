import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'dart:async';

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
    late Map<String, dynamic> decoded;
    decoded = json.decode(body) as Map<String, dynamic>;
    if (statusCode >= 200 && statusCode < 300) {
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ApiException('Client error ${response.statusCode}');
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error ${response.statusCode}');
    } else {
      throw ApiException('Unexpected status ${response.statusCode}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    throw UnimplementedError('TODO: Implement getMessages');
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement createMessage');
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError('TODO: Implement getHTTPStatus');
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('TODO: Implement healthCheck');
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
