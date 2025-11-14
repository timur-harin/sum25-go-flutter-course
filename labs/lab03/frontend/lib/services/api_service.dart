// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8888';
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
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.body}');
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.body}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException('Error ${response.statusCode}: ${response.body}');
      }

      final body = jsonDecode(response.body);

      // Если ответ — массив
      List<dynamic> list;
      if (body is List) {
        list = body;
      }
      // Если обёрнут в { data: [...] }
      else if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      } else {
        throw ApiException('Unexpected response format');
      }

      return list
          .map((item) => Message.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final error = request.validate();
    if (error != null) throw ValidationException(error);

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
        if (data.containsKey('id')) {
          return Message.fromJson(data);
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse =
              ApiResponse<Map<String, dynamic>>.fromJson(data, (d) => d as Map<String, dynamic>);
          return Message.fromJson(apiResponse.data!);
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final error = request.validate();
    if (error != null) throw ValidationException(error);

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
        if (data.containsKey('id')) {
          return Message.fromJson(data);
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse =
              ApiResponse<Map<String, dynamic>>.fromJson(data, (d) => d as Map<String, dynamic>);
          return Message.fromJson(apiResponse.data!);
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Delete failed: ${response.body}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode >= 600) {
      throw ValidationException('Invalid status code: $statusCode');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
        if (data.containsKey('status_code')) {
          return HTTPStatusResponse.fromJson(data);
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse =
              ApiResponse<Map<String, dynamic>>.fromJson(data, (d) => d as Map<String, dynamic>);
          return HTTPStatusResponse.fromJson(apiResponse.data!);
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed: ${response.body}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }
}

// Exceptions

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