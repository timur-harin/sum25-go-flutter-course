import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw NetworkException('Client error: ${response.statusCode} - ${response.body}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode} - ${response.body}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode} - ${response.body}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/messages'), headers: _getHeaders())
          .timeout(timeout);

      final decodedData = json.decode(response.body);
      
      // Handle both direct array and wrapped response formats
      List<dynamic> messagesData;
      if (decodedData is List) {
        messagesData = decodedData;
      } else if (decodedData is Map<String, dynamic> && decodedData['data'] is List) {
        messagesData = decodedData['data'];
      } else {
        throw ApiException('Invalid response format');
      }

      return messagesData.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
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
            Uri.parse('$baseUrl/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Map<String, dynamic>>>(
        response,
        (json) => ApiResponse.fromJson(json, (data) => data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return Message.fromJson(apiResponse.data!);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to create message');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
            Uri.parse('$baseUrl/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Map<String, dynamic>>>(
        response,
        (json) => ApiResponse.fromJson(json, (data) => data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return Message.fromJson(apiResponse.data!);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to update message');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Map<String, dynamic>>>(
        response,
        (json) => ApiResponse.fromJson(json, (data) => data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return HTTPStatusResponse.fromJson(apiResponse.data!);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is Map<String, dynamic>) {
          if (decodedData['success'] == true && decodedData['data'] != null) {
            return decodedData['data'] as Map<String, dynamic>;
          } else {
            return decodedData;
          }
        } else if (decodedData is String) {
          return {'status': decodedData};
        } else {
          return {'status': 'healthy'};
        }
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
