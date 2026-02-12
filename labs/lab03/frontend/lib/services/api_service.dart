import 'dart:convert';
import 'dart:async';
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

  Future<T> _handleResponse<T>(
    http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    final status = response.statusCode;
    dynamic body;

    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    } else {
      body = null;
    }

    if (status >= 200 && status < 300) {
      if (body is Map<String, dynamic>) {
        return fromJson(body);
      } else {
        throw ApiException('Invalid JSON response');
      }
    } else if (status >= 400 && status < 500) {
      // Ошибка клиента — если body Map с error, берем ошибку, иначе строку или статус
      final message = (body is Map && body['error'] != null)
          ? body['error']
          : (body is String ? body : 'Client error: $status');
      throw ApiException(message);
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error: $status');
    } else {
      throw ApiException('Unexpected error: $status');
    }
  }


  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<List<Message>>(response, (json) {
        final List<dynamic> data = json['data'];
        return data.map((item) => Message.fromJson(item)).toList();
      });
    } catch (e) {
      throw ApiException('Failed to get messages: $e');
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
      return _handleResponse<Message>(
          response, (json) => Message.fromJson(json['data']));
    } catch (e) {
      throw ApiException('Failed to create message: $e');
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
      return _handleResponse<Message>(
          response, (json) => Message.fromJson(json['data']));
    } catch (e) {
      throw ApiException('Failed to update message: $e');
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
      throw ApiException('Delete failed: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode >= 600) {
      throw ValidationException('Invalid status code: $statusCode');
    }

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'),
              headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<HTTPStatusResponse>(
          response, (json) => HTTPStatusResponse.fromJson(json['data']));
    } catch (e) {
      throw ApiException('Failed to get HTTP status: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Health check error: $e');
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
