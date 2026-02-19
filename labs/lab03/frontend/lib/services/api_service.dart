import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8081';
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
      final Map<String, dynamic> decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['error'] ?? 'Client error occurred';
      throw ValidationException(errorMessage);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
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
        (json) => ApiResponse.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> messagesJson = apiResponse.data as List<dynamic>;
        return messagesJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to get messages');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get messages: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
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
        (json) => ApiResponse.fromJson(
          json,
          (data) => Message.fromJson(data),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to create message');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create message: $e');
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
        (json) => ApiResponse.fromJson(
          json,
          (data) => Message.fromJson(data),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to update message');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update message: $e');
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

      if (response.statusCode == 204) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw ValidationException('Message not found');
      } else {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete message: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (json) => ApiResponse.fromJson(
          json,
          (data) => HTTPStatusResponse.fromJson(data),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get HTTP status: $e');
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
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
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

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
