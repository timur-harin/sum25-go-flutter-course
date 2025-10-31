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
      http.Response response, T Function(dynamic json) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = jsonDecode(response.body);
      return fromJson(jsonData['data']);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException(jsonDecode(response.body)['error'] ??
          'Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }


  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<List<Message>>(response, (json) {
        return (json as List).map((e) => Message.fromJson(e)).toList();
      });
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) {
      throw ValidationException(validation);
    }

    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      )
          .timeout(timeout);
      return _handleResponse<Message>(response, (json) {
        return Message.fromJson(json);
      });
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) {
      throw ValidationException(validation);
    }

    try {
      final response = await _client
          .put(
        Uri.parse('$baseUrl/api/messages/$id'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      )
          .timeout(timeout);
      return _handleResponse<Message>(response, (json) {
        return Message.fromJson(json);
      });
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException(
            'Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ApiException('Invalid HTTP status code');
    }

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'),
          headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<HTTPStatusResponse>(
          response, (json) => HTTPStatusResponse.fromJson(json));
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Health check failed');
      }
    } catch (e) {
      throw NetworkException(e.toString());
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
