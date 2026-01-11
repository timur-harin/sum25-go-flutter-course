import 'dart:convert';
import 'dart:async';
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
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        throw ApiException('Empty response body');
      }
      try {
        final decoded = json.decode(responseBody) as Map<String, dynamic>;
        return fromJson(decoded);
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else if (statusCode >= 400 && statusCode < 500) {
      String message = 'Client error';
      try {
        final error = json.decode(responseBody) as Map<String, dynamic>;
        message = error['error'] ?? message;
      } catch (_) {}
      throw ClientException(message);
    } else if (statusCode >= 500) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected status code: $statusCode');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final uri = Uri.parse('$baseUrl/api/messages');
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse<List<Message>>(
        response,
        (json) {
          // Исправляем обработку ответа - используем 'data' вместо 'messages'
          final data = json['data'] as List?;
          if (data == null) {
            throw ApiException('Missing data field in response');
          }
          return data
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to fetch messages: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      final validationError = request.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }

      final uri = Uri.parse('$baseUrl/api/messages');
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to create message: $e');
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final validationError = request.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }

      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to update message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to delete message: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final uri = Uri.parse('$baseUrl/api/status/$statusCode');
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(
        response,
        (json) => HTTPStatusResponse.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to get HTTP status: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return json.decode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Health check failed: $e');
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

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
