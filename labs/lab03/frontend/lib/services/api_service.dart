import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/message.dart';

/// Base exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Exception for network-related errors
class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

/// Exception for server-side errors (5xx)
class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

/// Exception for validation failures
class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

/// Service to interact with backend API
class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  late final http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }

  /// Common headers for all requests
  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Retrieve all messages
  Future<List<Message>> getMessages() async {
    throw UnimplementedError('TODO: Implement getMessage');

    final uri = Uri.parse('$baseUrl/api/messages');
    http.Response response;
    try {
      response =
          await _client.get(uri, headers: _getHeaders()).timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiException('Failed to load messages: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    if (jsonMap['success'] != true) {
      throw ApiException(jsonMap['error'] as String? ?? 'Unknown error');
    }

    final List<dynamic> data = jsonMap['data'] as List<dynamic>;
    return data
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement createMessage');

    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final uri = Uri.parse('$baseUrl/api/messages');
    final body = json.encode(request.toJson());
    http.Response response;
    try {
      response = await _client
          .post(uri, headers: _getHeaders(), body: body)
          .timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode != 201) {
      throw ApiException('Failed to create message: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    if (jsonMap['success'] != true) {
      throw ApiException(jsonMap['error'] as String? ?? 'Unknown error');
    }

    return Message.fromJson(jsonMap['data'] as Map<String, dynamic>);
  }

  /// Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement updateMessage');

    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final uri = Uri.parse('$baseUrl/api/messages/$id');
    final body = json.encode(request.toJson());
    http.Response response;
    try {
      response = await _client
          .put(uri, headers: _getHeaders(), body: body)
          .timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode == 404) {
      throw ApiException('Message not found');
    } else if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiException('Failed to update message: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    if (jsonMap['success'] != true) {
      throw ApiException(jsonMap['error'] as String? ?? 'Unknown error');
    }

    return Message.fromJson(jsonMap['data'] as Map<String, dynamic>);
  }

  /// Delete a message
  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('TODO: Implement deleteMessage');

    final uri = Uri.parse('$baseUrl/api/messages/$id');
    http.Response response;
    try {
      response =
          await _client.delete(uri, headers: _getHeaders()).timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode != 204) {
      throw ApiException('Failed to delete message: ${response.statusCode}');
    }
  }

  /// Fetch HTTP status info
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError('TODO: Implement getHTTP');

    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException('Status code must be between 100 and 599');
    }

    final uri = Uri.parse('$baseUrl/api/status/$statusCode');
    http.Response response;
    try {
      response =
          await _client.get(uri, headers: _getHeaders()).timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode != 200) {
      throw ApiException('Failed to load HTTP status: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    if (jsonMap['success'] != true) {
      throw ApiException(jsonMap['error'] as String? ?? 'Unknown error');
    }

    return HTTPStatusResponse.fromJson(jsonMap['data'] as Map<String, dynamic>);
  }

  /// Health check endpoint
  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('TODO: Implement healthCheck');

    final uri = Uri.parse('$baseUrl/api/health');
    http.Response response;
    try {
      response =
          await _client.get(uri, headers: _getHeaders()).timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode != 200) {
      throw ApiException('Health check failed: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    if (jsonMap['success'] != true) {
      throw ApiException(jsonMap['error'] as String? ?? 'Unknown error');
    }

    return jsonMap['data'] as Map<String, dynamic>;
  }
}
