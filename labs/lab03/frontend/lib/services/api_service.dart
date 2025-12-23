import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'http://localhost:8080';

  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);

  // TODO: Add late http.Client _client field
  late http.Client _client;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
  }

  // TODO: Add dispose() method that calls _client.close();
  void dispose() {
    _client.close();
  }

  // TODO: Add _getHeaders() method that returns Map<String, String>
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // TODO: Add _handleResponse<T>() method with parameters:
  T _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        throw ApiException('Empty response body');
      }
      try {
        final decoded = json.decode(body) as Map<String, dynamic>;
        return fromJson(decoded);
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else if (statusCode >= 400 && statusCode < 500) {
      String message = 'Client error';
      try {
        final decoded = json.decode(body) as Map<String, dynamic>;
        message = decoded['error'] ?? message;
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
          final list = json['data'] as List?;
          if (list == null) {
            throw ApiException('Missing data field in response');
          }
          return list
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
            (json) => Message.fromJson(json['data']),
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
            (json) => Message.fromJson(json['data']),
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
            (json) => HTTPStatusResponse.fromJson(json['data']),
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
  // TODO: Add final String message field
  final String message;

  // TODO: Add constructor ApiException(this.message);
  ApiException(this.message);

  // TODO: Override toString() to return 'ApiException: $message'
  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  // TODO: Add constructor NetworkException(String message) : super(message);
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  // TODO: Add constructor ServerException(String message) : super(message);
  ServerException(String message) : super(message);
}

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}

class ValidationException extends ApiException {
  // TODO: Add constructor ValidationException(String message) : super(message);
  ValidationException(String message) : super(message);
}