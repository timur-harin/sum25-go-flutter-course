import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService() : _client = http.Client();

  void dispose() => _client.close();

  Map<String, String> _getHeaders() =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  T _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return fromJson(jsonDecode(response.body));
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw NetworkException('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ServerException('Server error: ${response.statusCode}');
    }
    throw ApiException('Unexpected error: ${response.statusCode}');
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'))
          .timeout(timeout);
      return _handleResponse(response,
          (json) => (json as List).map((e) => Message.fromJson(e)).toList());
    } catch (e) {
      throw UnimplementedError('Failed to load messages: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      if (request.validate() != null)
        throw UnimplementedError(request.validate()!);
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              body: jsonEncode(request.toJson()), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(
          response, (json) => Message.fromJson(json['data']));
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      if (request.validate() != null)
        throw UnimplementedError(request.validate()!);
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              body: jsonEncode(request.toJson()), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(
          response, (json) => Message.fromJson(json['data']));
    } catch (e) {
      throw UnimplementedError('Failed to update message: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'))
          .timeout(timeout);
      if (response.statusCode != 204) throw ApiException('Deletion failed');
    } catch (e) {
      throw UnimplementedError('Failed to delete message: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'))
          .timeout(timeout);
      return _handleResponse(
          response, (json) => HTTPStatusResponse.fromJson(json['data']));
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response =
          await _client.get(Uri.parse('$baseUrl/api/health')).timeout(timeout);
      return jsonDecode(response.body);
    } catch (e) {
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
