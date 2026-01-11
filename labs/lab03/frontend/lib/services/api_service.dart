import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  void dispose() {
    client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final statusCode = response.statusCode;
    if (200 <= statusCode && statusCode <= 299) {
      final decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (400 <= statusCode && statusCode <= 499) {
      final errorMsg = json.decode(response.body)['message'];
      throw ApiException(errorMsg);
    } else if (500 <= statusCode && statusCode <= 599) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected status code: $statusCode');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response =
          await client.get(Uri.parse('$baseUrl/api/messages')).timeout(timeout);

      final json = jsonDecode(response.body);

      if (json['data'] == null && json['success'] == true) {
        return [];
      } else if (json['data'] is List) {
        return (json['data'] as List).map((e) => Message.fromJson(e)).toList();
      } else {
        throw ApiException('Unexpected response format: ${response.body}');
      }
    } catch (e) {
      throw ApiException("error: $e");
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      request.validate();
      final response = await client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      return _handleResponse(response, (apiResponse) {
        final message = apiResponse['data'] as Map<String, dynamic>;
        return Message.fromJson(message);
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException("error while creating message");
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      request.validate(); // Validate the request
      final response = await client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(
        response,
        (data) => Message.fromJson(data['data']),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException("error while updating message");
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (response.statusCode != 204) {
        final errorMsg =
            json.decode(response.body)['message'] ?? 'Failed to delete message';
        throw ApiException(errorMsg);
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ServerException("error while deleting message");
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      return _handleResponse(
        response,
        (data) => HTTPStatusResponse.fromJson(data['data']),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw const ApiException("error while getting status");
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (200 <= response.statusCode && response.statusCode <= 299) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorMsg =
            json.decode(response.body)['message'] ?? 'Health check failed';
        throw ApiException(errorMsg);
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw UnimplementedError();
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

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
