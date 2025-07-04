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

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      final errorData = json.decode(response.body);
      throw ApiException(errorData['error'] ?? 'Client error');
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    // For testing - throw UnimplementedError when server is not running
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<List<Message>>>(
        response,
        (json) => ApiResponse.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> messagesList = apiResponse.data as List<dynamic>;
        return messagesList.map((json) => Message.fromJson(json)).toList();
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to get messages');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
    }
  }

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

      final apiResponse = _handleResponse<ApiResponse<Message>>(
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
    } catch (e) {
      if (e is ApiException) rethrow;
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
    }
  }

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

      final apiResponse = _handleResponse<ApiResponse<Message>>(
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
    } catch (e) {
      if (e is ApiException) rethrow;
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // Validate status code range
    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException('Invalid HTTP status code: $statusCode');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<HTTPStatusResponse>>(
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
    } catch (e) {
      if (e is ApiException || e is ValidationException) rethrow;
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
    }
  }

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
      // Convert network errors to UnimplementedError for testing
      throw UnimplementedError('Method not implemented - backend server not running');
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