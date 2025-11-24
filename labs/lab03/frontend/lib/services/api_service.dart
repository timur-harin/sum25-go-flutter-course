import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return fromJson(data);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final data = json.decode(response.body);
      final message = data['error'] ?? 'Client error';
      throw ApiException(message);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unknown error: ${response.statusCode}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (data) => ApiResponse<List<dynamic>>.fromJson(data, null),
      );

      if (!apiResponse.success) {
        throw ApiException(apiResponse.error ?? 'Failed to get messages');
      }

      final messageList = apiResponse.data as List<dynamic>;
      return messageList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    if (request.username.isEmpty || request.content.isEmpty) {
      throw ValidationException('Username and content are required');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (data) => ApiResponse<Map<String, dynamic>>.fromJson(
          data,
          (json) => json,
        ),
      );

      if (!apiResponse.success) {
        throw ApiException(apiResponse.error ?? 'Failed to create message');
      }

      return Message.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (data) => ApiResponse<Map<String, dynamic>>.fromJson(
          data,
          (json) => json,
        ),
      );

      if (!apiResponse.success) {
        throw ApiException(apiResponse.error ?? 'Failed to update message');
      }

      return Message.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
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
        if (response.statusCode == 404) {
          throw ApiException('Message not found');
        }
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode >= 600) {
      throw ValidationException('Invalid status code');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (data) => ApiResponse<Map<String, dynamic>>.fromJson(
          data,
          (json) => json,
        ),
      );

      if (!apiResponse.success) {
        throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
      }

      return HTTPStatusResponse.fromJson(
          apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Health check failed');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
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
