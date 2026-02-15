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
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<T> _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    final status = response.statusCode;
    final body = response.body;

    if (status >= 200 && status < 300) {
      final Map<String, dynamic> decoded = json.decode(body);
      return fromJson(decoded);
    } else if (status >= 400 && status < 500) {
      String message;
      try {
        final errorData = json.decode(body);
        message = errorData['error'] ?? 'Client error $status';
      } catch (_) {
        message = 'Client error $status';
      }
      throw ValidationException(message);
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error $status');
    } else {
      throw ApiException('Unexpected error: HTTP $status');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(response, (json) {
        final data = json['data'] as List<dynamic>;
        return data.map((e) => Message.fromJson(e)).toList();
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      return _handleResponse(response, (json) {
        final data = json['data'];
        return Message.fromJson(data);
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      return _handleResponse(response, (json) {
        final data = json['data'];
        return Message.fromJson(data);
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
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(response, (json) {
        final data = json['data'];
        return HTTPStatusResponse.fromJson(data);
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
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed with status ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }
}

// Кастомные исключения

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
