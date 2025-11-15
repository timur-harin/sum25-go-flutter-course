import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

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

T _handleResponse<T>(
  http.Response response,
  T Function(dynamic) fromJson,
) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final decodedData = json.decode(response.body);
    // Handle both cases: when response is a list and when it's a map with 'data'
    if (decodedData is List) {
      return fromJson(decodedData);
    } else if (decodedData is Map && decodedData.containsKey('data')) {
      return fromJson(decodedData['data']);
    } else {
      return fromJson(decodedData);
    }
  } else if (response.statusCode >= 400 && response.statusCode < 500) {
    throw ApiException('Client error: ${response.statusCode}');
  } else if (response.statusCode >= 500 && response.statusCode < 600) {
    throw ServerException('Server error: ${response.statusCode}');
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
      return (data as List).map((e) => Message.fromJson(e)).toList();
    });
  } catch (e) {
    if (e is http.ClientException) {
      throw NetworkException('Network error: ${e.message}');
    } else if (e is Exception) {
      // Добавляем обработку общего Exception
      throw NetworkException('Network error: ${e.toString()}');
    }
    rethrow;
  }
}
  Future<Message> createMessage(CreateMessageRequest request) async {
    request.validate();
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (data) => Message.fromJson(data));
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    request.validate();
    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (data) => Message.fromJson(data));
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      }
      rethrow;
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
    final response = await _client
        .get(
          Uri.parse('$baseUrl/api/status/$statusCode'),
          headers: _getHeaders(),
        )
        .timeout(timeout);
    return _handleResponse(
        response, (data) => HTTPStatusResponse.fromJson(data));
  } catch (e) {
    if (e is http.ClientException) {
      throw NetworkException('Network error: ${e.message}');
    } else if (e.toString().contains('TimeoutException') || 
               e.toString().contains('timed out')) {
      throw NetworkException('Request timed out');
    } else if (e is Exception) {
      throw NetworkException('Network error: ${e.toString()}');
    }
    rethrow;
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
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    
    if (decoded.isEmpty || !decoded.containsKey('status')) {
      return {'status': 'healthy'};
    }
    
    return decoded;
  } catch (e) {
    if (e is http.ClientException) {
      throw NetworkException('Network error: ${e.message}');
    }
    rethrow;
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
