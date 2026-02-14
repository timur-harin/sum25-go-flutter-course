import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
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
          .get(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
        if (data is List) {
          return (data as List<dynamic>)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse =
              ApiResponse<List<dynamic>>.fromJson(data, (d) => d);
          return (apiResponse.data as List<dynamic>)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
  final error = request.validate();
  if (error != null) throw ValidationException(error);

  try {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    ).timeout(timeout);

    return _handleResponse(response, (data) {
      if (data.containsKey('id')) return Message.fromJson(data);
      if (data.containsKey('success') && data.containsKey('data')) {
        return Message.fromJson(data['data']);
      }
      throw ApiException('Unexpected response format');
    });
  } on http.ClientException catch (e) {
    throw NetworkException('Network error: ${e.message}');
  } on ApiException {
    rethrow;
  } catch (e) {
    throw NetworkException('Network error: $e');
  }
}

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
      if (data.containsKey('id')) return Message.fromJson(data);
      if (data.containsKey('success') && data.containsKey('data')) {
        return Message.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw ApiException('Unexpected response format');
    });
  } on http.ClientException catch (e) {
    throw NetworkException('Network error: ${e.message}');
  } on ApiException {
    rethrow;
  } catch (e) {
    throw NetworkException('Network error: $e');
  }
}

  Future<void> deleteMessage(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode >= 600) {
      throw ValidationException('Invalid status code: $statusCode');
    }

    try {
      final uri = Uri.parse('$baseUrl/api/status/$statusCode');
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleResponse(response, (data) {
  final responseData = (data.containsKey('success') && data.containsKey('data'))
      ? data['data'] as Map<String, dynamic>
      : data;
  
  if (!responseData.containsKey('status_code')) {
    throw ApiException('Invalid response format: missing status_code');
  }
  
  return HTTPStatusResponse.fromJson(responseData);
});
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Health check failed: ${response.body}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
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