import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return fromJson(jsonMap);
    } else if (statusCode >= 400 && statusCode < 500) {
      String message = 'Client error: $statusCode';
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody['error'] ?? message;
      } catch (_) {}
      throw ApiException(message);
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected error: $statusCode');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse(
        response,
            (json) => ApiResponse<List<Message>>(
          success: json['success'],
          error: json['error'],
          data: (json['data'] as List<dynamic>)
              .map((e) => Message.fromJson(e))
              .toList(),
        ),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(apiResponse.error ?? 'Unknown error');
      }

      return apiResponse.data!;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    final apiResponse = _handleResponse(response, (json) =>
    ApiResponse<Message>.fromJson(json, (m) => Message.fromJson(m)));

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(apiResponse.error ?? 'Unknown error');
    }

    return apiResponse.data!;
  }


  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final response = await _client.put(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    final apiResponse = _handleResponse(response, (json) =>
    ApiResponse<Message>.fromJson(json, (m) => Message.fromJson(m)));

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(apiResponse.error ?? 'Unknown error');
    }

    return apiResponse.data!;
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw ApiException('Failed to delete message (status ${response.statusCode})');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/status/$statusCode'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse(
        response,
            (json) => ApiResponse<HTTPStatusResponse>.fromJson(
          json,
              (j) => HTTPStatusResponse.fromJson(j),
        ),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(apiResponse.error ?? 'Failed to load status');
      }

      return apiResponse.data!;
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/health'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException('Health check failed: ${response.statusCode}');
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() {
    return 'ApiException: $message';
  }
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
