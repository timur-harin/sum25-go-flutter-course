import 'dart:async';
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
      T Function(dynamic) fromJson,
      ) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      return fromJson(decodedData);
    } else if (statusCode >= 400 && statusCode < 500) {
      final error = json.decode(response.body)['message'] ?? 'Client error';
      throw ApiException('$error (Status: $statusCode)');
    } else if (statusCode >= 500) {
      throw ServerException('Server error (Status: $statusCode)');
    } else {
      throw ApiException('Unexpected error (Status: $statusCode)');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    final uri = Uri.parse('$baseUrl/api/messages');
    try {
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse<List<Message>>(
        response,
            (data) => (data as List).map((e) => Message.fromJson(e)).toList(),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    request.validate();
    final uri = Uri.parse('$baseUrl/api/messages');
    final body = json.encode(request.toJson());

    try {
      final response = await _client
          .post(uri, headers: _getHeaders(), body: body)
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
            (data) => Message.fromJson(data['data']),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    request.validate();
    final uri = Uri.parse('$baseUrl/api/messages/$id');
    final body = json.encode(request.toJson());

    try {
      final response = await _client
          .put(uri, headers: _getHeaders(), body: body)
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
            (data) => Message.fromJson(data['data']),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    final uri = Uri.parse('$baseUrl/api/messages/$id');
    try {
      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Deletion failed (Status: ${response.statusCode})');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    final uri = Uri.parse('$baseUrl/api/status/$statusCode');
    try {
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(
        response,
            (data) => HTTPStatusResponse.fromJson(data['data']),
      );
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final uri = Uri.parse('$baseUrl/api/health');
    try {
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Health check failed (Status: ${response.statusCode})');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
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
