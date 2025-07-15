import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;

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
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final statusCode = response.statusCode;
    final decoded = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded['success'] == true && decoded['data'] != null) {
        return fromJson(decoded['data']);
      } else {
        throw ApiException(decoded['error'] ?? 'Unknown error');
      }
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(decoded['error'] ?? 'Client error');
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected response code: $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List data = decoded['data'];
        return data.map((e) => Message.fromJson(e)).toList();
      } else {
        throw ApiException(decoded['error'] ?? 'Failed to load messages');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
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
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (json) => Message.fromJson(json));
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
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
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (json) => Message.fromJson(json));
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (response.statusCode != 204) {
        final decoded = json.decode(response.body);
        throw ApiException(decoded['error'] ?? 'Failed to delete message');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ApiException('Invalid status code');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      return _handleResponse(response, (json) => HTTPStatusResponse.fromJson(json));
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      return json.decode(response.body);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException(e.toString());
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
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
