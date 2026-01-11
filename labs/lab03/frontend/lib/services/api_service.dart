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
  

  void dispose(){
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
          'Content-Type': 'application/json',
        'Accept': 'application/json',
    };
  }


  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final data = jsonBody['data'];
      return fromJson(data);
    } else if (statusCode >= 400 && statusCode < 500) {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      throw ValidationException(errorBody['error'] ?? 'Client error');
    } else if (statusCode >= 500) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected error: $statusCode');
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
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
