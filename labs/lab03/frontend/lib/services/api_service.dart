import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Message>> getMessages() async {
    try {
      final resp = await _client
        .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
        .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
      }
      final bodyMap = json.decode(resp.body);
      if (bodyMap is! Map<String, dynamic>) {
        throw ApiException('Unexpected response format');
      }
      // check both lowercase and uppercase keys
      final success = (bodyMap['success'] as bool?) ?? (bodyMap['Success'] as bool?);
      final rawData = bodyMap['data'] ?? bodyMap['Data'];
      if (success != true || rawData is! List) {
        throw ApiException('Unexpected response format');
      }
      return (rawData as List)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final resp = await _client
        .post(
          Uri.parse('$baseUrl/api/messages'),
          headers: _getHeaders(),
          body: json.encode(request.toJson()),
        )
        .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
      }
      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return Message.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final resp = await _client
        .put(
          Uri.parse('$baseUrl/api/messages/$id'),
          headers: _getHeaders(),
          body: json.encode(request.toJson()),
        )
        .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
      }
      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return Message.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final resp = await _client
        .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
        .timeout(timeout);
      if (resp.statusCode != 204) {
        throw ApiException('Delete failed: HTTP ${resp.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int code) async {
    if (code < 100 || code > 599) throw ValidationException('Invalid HTTP status code');
    try {
      final resp = await _client
        .get(Uri.parse('$baseUrl/api/status/$code'), headers: _getHeaders())
        .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
      }
      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return HTTPStatusResponse(
        statusCode: data['status_code'] as int,
        imageUrl: '$baseUrl/api/cat/$code',
        description: data['description'] as String,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final resp = await _client
        .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
        .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
      }
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
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
