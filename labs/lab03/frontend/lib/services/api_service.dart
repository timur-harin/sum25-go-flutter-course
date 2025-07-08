import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lab03_frontend/models/message.dart';

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

  void _handleTestEnvironment() {
    throw UnimplementedError('TODO: Implement this method');
  }

  Future<List<Message>> getMessages() async {
    _handleTestEnvironment();
    return [];
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    _handleTestEnvironment();
    return Message(
      id: 0,
      username: '',
      content: '',
      timestamp: DateTime.now(),
    );
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    _handleTestEnvironment();
    return Message(
      id: 0,
      username: '',
      content: '',
      timestamp: DateTime.now(),
    );
  }

  Future<void> deleteMessage(int id) async {
    _handleTestEnvironment();
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    _handleTestEnvironment();
    return HTTPStatusResponse(
      statusCode: 0,
      imageUrl: '',
      description: '',
    );
  }

  Future<Map<String, dynamic>> healthCheck() async {
    _handleTestEnvironment();
    return {};
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

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}
