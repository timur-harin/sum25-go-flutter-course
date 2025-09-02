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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      if (decoded.containsKey('data')) {
        return fromJson(decoded['data']);
      } else {
        // For healthCheck and simple endpoints
        return fromJson(decoded);
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.body}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.body}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    throw UnimplementedError('help');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('...');
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
        (json) => Message.fromJson(json),
      );
    } catch (e) {
      throw UnimplementedError('help');
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
        throw UnimplementedError('help');
        ;
      }
    } catch (e) {
      throw UnimplementedError('help');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw UnimplementedError('help');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(
        response,
        (json) => HTTPStatusResponse(
          statusCode: json['status_code'],
          imageUrl: json['image_url'],
          description: json['description'],
        ),
      );
    } catch (e) {
      throw UnimplementedError('help');
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

      return json.decode(response.body);
    } catch (e) {
      throw UnimplementedError('help');
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
