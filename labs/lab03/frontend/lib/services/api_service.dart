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

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw UnimplementedError();
      }
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    if (request.username.isEmpty || request.content.isEmpty) {
      throw ValidationException('Validation failed');
    }
    throw UnimplementedError();
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    if (request.content.isEmpty) {
      throw ValidationException('Validation failed');
    }
    throw UnimplementedError();
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError();
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError();
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