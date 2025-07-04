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

  _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode > 299 || response.statusCode < 200) {
      return;
    }
    Map<String, dynamic> decodedData = jsonDecode(response.toString());
    return fromJson(decodedData);
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['messages'] as List<dynamic>;
      return data.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      // throw NetworkException('Failed to load messages: $e');
      throw UnimplementedError();
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      // throw ValidationException(validationError);
      throw UnimplementedError();
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['message'] as Map<String, dynamic>;
      return Message.fromJson(data);
    } catch (e) {
      // throw NetworkException('Failed to create message: $e');
      throw UnimplementedError();
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      // throw ValidationException(validationError);
      throw UnimplementedError();
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['message'] as Map<String, dynamic>;
      return Message.fromJson(data);
    } catch (e) {
      // throw NetworkException('Failed to update message: $e');
      throw UnimplementedError();
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException(
            'Failed to delete message (status: ${response.statusCode})');
      }
    } catch (e) {
      // throw NetworkException('Failed to delete message: $e');
      throw UnimplementedError();
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'),
              headers: _getHeaders())
          .timeout(timeout);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['status'] as Map<String, dynamic>;
      return HTTPStatusResponse.fromJson(data);
    } catch (e) {
      // throw NetworkException('Failed to get HTTP status: $e');
      throw UnimplementedError();
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // throw NetworkException('Failed to perform health check: $e');
      throw UnimplementedError();
    }
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
