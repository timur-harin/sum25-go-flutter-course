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
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return fromJson(decoded);
    } else if (status >= 400 && status < 500) {
      String message = 'Client error';
      try {
        final Map<String, dynamic> decoded = json.decode(response.body);
        message = decoded['error'] ?? message;
      } catch (_) {}
      throw ApiException(message);
    } else if (status >= 500 && status < 600) {
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
      final apiResponse = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );
      final List<dynamic> data = apiResponse['data'] ?? [];
      return data.map((e) => Message.fromJson(e)).toList();
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
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
      final apiResponse = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );
      return Message.fromJson(apiResponse['data']);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
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
      final apiResponse = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );
      return Message.fromJson(apiResponse['data']);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
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
        throw ApiException('Failed to delete message');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      final apiResponse = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );
      return HTTPStatusResponse.fromJson(apiResponse['data']);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw UnimplementedError();
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
