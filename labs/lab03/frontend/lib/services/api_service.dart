import 'dart:async';
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

  dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  dynamic _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = jsonDecode(response.body);

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('success')) {
        final apiResponse = ApiResponse.fromJson(decodedData);
        if (!apiResponse.success) {
          throw ApiException(apiResponse.error ?? 'Request failed');
        }
        if (apiResponse.data is List) {
          return (apiResponse.data as List)
              .map((item) => fromJson(item))
              .toList();
        } else if (apiResponse.data is Map<String, dynamic>) {
          return fromJson(apiResponse.data);
        }
      }

      if (decodedData is List) {
        return decodedData.map((item) => fromJson(item)).toList();
      } else if (decodedData is Map<String, dynamic>) {
        return fromJson(decodedData);
      }

      throw ApiException('Invalid response format');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw NetworkException('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected status code: ${response.statusCode}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, Message.fromJson);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get messages: $e');
    }

    throw UnimplementedError('TODO: Implement getMessages');
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }

    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
          headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);

      return _handleResponse<Message>(response, Message.fromJson);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create message: $e');
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }

    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
          headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);

      return _handleResponse<Message>(response, Message.fromJson);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final apiResponse = await _client.delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders()).timeout(timeout);
      if (apiResponse.statusCode == 204) {
        return;
      }
      if (apiResponse.statusCode == 404) {
        throw ApiException('Failed to delete message');
      }
      if (apiResponse.statusCode >= 400 && apiResponse.statusCode < 500) {
        throw NetworkException('Client error: ${apiResponse.statusCode}');
      } else if (apiResponse.statusCode >= 500) {
        throw ServerException('Server error: ${apiResponse.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${apiResponse.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch(e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete message: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode >= 600) {
      throw ApiException('Invalid HTTP status code: $statusCode. Must be between 100 and 599.');
    }
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(
          response, (json) => HTTPStatusResponse.fromJson(json));
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get HTTP status: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw ServerException('Health check failed: ${response.statusCode}');
    } on TimeoutException {
      throw NetworkException('Request timed out');
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
  String toString() {
    return 'ApiException: $message';
  }
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
