import 'dart:async';
import 'dart:convert';

import '../models/message.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.body.isEmpty) {
      throw ApiException("Response body is empty");
    }
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final Map<String, dynamic> decodedData = jsonDecode(response.body);
      return fromJson(decodedData);
    }
    throw UnimplementedError("Error");
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
        final response = await _client.get(
        Uri.parse("$baseUrl/api/messages"),
        headers: _getHeaders()
      ).timeout(timeout);
      return _handleResponse(response, (data) => ((data["data"] as List).map((value) => Message.fromJson(value))).toList());
    }
    on NetworkException catch(_) {
      throw NetworkException("Network error");
    }
    on TimeoutException catch(_) {
      throw TimeoutException("Timeout");
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      if (request.validate() == null) {
        final body = jsonEncode(request.toJson());
        final response = await _client.post(
          Uri.parse("$baseUrl/api/messages"),
          headers: _getHeaders(),
          body: body
        ).timeout(timeout);
        final finalResponse = _handleResponse(response, (data) => ApiResponse.fromJson(data, (json) => Message.fromJson(json)));
        return finalResponse.data!;
      }
    }
    on TimeoutException catch(_) {
      throw TimeoutException("Timeout");
    }
    throw UnimplementedError('TODO: Implement createMessage');
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      if (request.validate() == null) {
        final body = jsonEncode(request.toJson());
        final response = await _client.put(
          Uri.parse("$baseUrl/api/messages/$id"),
          headers: _getHeaders(),
          body: body
        );
        final finalResponse = _handleResponse(response, (data) => ApiResponse.fromJson(data, (json) => Message.fromJson(json)));
        return finalResponse.data!;
      }
    }
    on Exception catch(_) {
      throw ApiException("Not Found");
    }
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse("$baseUrl/api/messages/$id"),
        headers: _getHeaders()
      ).timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException("Not Found");
      }
    }
    on Exception catch(_) {
      throw ApiException("Not Found");
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException("Invalid status code");
    }
    final response = await _client.get(
      Uri.parse("$baseUrl/api/status/$statusCode")
    );
    final finalResponse = _handleResponse(response, (data) => ApiResponse.fromJson(data, (json) => HTTPStatusResponse.fromJson(json)));
    return finalResponse.data!;
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _client.get(
      Uri.parse("$baseUrl/api/health"),
      headers: _getHeaders()
    ).timeout(timeout);
    return jsonDecode(response.body);
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
