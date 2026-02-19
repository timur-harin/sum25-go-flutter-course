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
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'))
          .timeout(timeout);

      return _handleResponse<List<Message>>(
        response,
        (json) =>
            (json['data'] as List).map((msg) => Message.fromJson(msg)).toList(),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data']),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data']),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'))
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'))
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(
        response,
        (json) => HTTPStatusResponse.fromJson(json['data']),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response =
          await _client.get(Uri.parse('$baseUrl/api/health')).timeout(timeout);

      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
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
