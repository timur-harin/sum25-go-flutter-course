import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/src/mock_client.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client client;

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

  Future<T> _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.body}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.body}');
    } else {
      throw Exception('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (data) {
        final list = data['data'] as List<dynamic>; // <-- changed: use 'data' key instead of 'messages';
        return list.map((m) => Message.fromJson(m as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      throw NetworkException('Failed to load messages: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    if (request.validate() != null) {
      throw ValidationException(request.validate()!);
    }

    try {
      final response = await client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(),
              body: json.encode(request.toJson()))
          .timeout(timeout);

      return _handleResponse(response, (data) {
        return Message.fromJson(data['data']);
      });
    } catch (e) {
      throw NetworkException('Failed to create message: $e');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    if (request.validate() != null) {
      throw ValidationException(request.validate()!);
    }

    try {
      final response = await client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(),
              body: json.encode(request.toJson()))
          .timeout(timeout);

      return _handleResponse(response, (data) {
        return Message.fromJson(data['data']);
      });
    } catch (e) {
      throw NetworkException('Failed to update message: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      throw NetworkException('Failed to delete message: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'),
              headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (data) {
        return HTTPStatusResponse.fromJson(data);
      });
    } catch (e) {
      throw NetworkException('Failed to fetch HTTP status: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (data) => data);
    } catch (e) {
      throw NetworkException('Failed to check health: $e');
    }
  }
}

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
