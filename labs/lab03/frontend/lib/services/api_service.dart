import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field
  late http.Client _client;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService() {
    _client = http.Client();
  }

  // TODO: Add dispose() method that calls _client.close();
  void dispose() {
    _client.close();
  }

  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // TODO: Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
  // If 400-499, throw client error with message from response
  // If 500-599, throw server error
  // For other status codes, throw general error
  Future<T> _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    final code = response.statusCode;
    final body = response.body;
    dynamic jsonData;
    try {
      jsonData = json.decode(body);
    } catch (_) {
      jsonData = null;
    }
    if (code >= 200 && code < 300) {
      if (jsonData == null) {
        throw ApiException('Empty response body');
      }
      return fromJson(jsonData as Map<String, dynamic>);
    } else if (code >= 400 && code < 500) {
      throw NetworkException('Client error ${response.statusCode}: ${response.body}');
    } else if (code >= 500 && code < 600) {
      throw ServerException('Server error ${response.statusCode}');
    } else {
      throw ApiException('Unexpected HTTP status: $code');
    }
  }

  // Get all messages
  // Future<List<Message>> getMessages() async {
  //   // TODO: Implement getMessages
  //   // Make GET request to '$baseUrl/api/messages'
  //   // Use _handleResponse to parse response into List<Message>
  //   // Handle network errors and timeouts
  //   final uri = Uri.parse('$baseUrl/api/messages');
  //   try {
  //     final resp = await _client
  //         .get(uri, headers: _getHeaders())
  //         .timeout(timeout);
  //     final list = json.decode(resp.body) as List<dynamic>;
  //     return list.map((e) => Message.fromJson(e)).toList();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  Future<List<Message>> getMessages() {
    throw UnimplementedError();
  }

  // Create a new message
  // Future<Message> createMessage(CreateMessageRequest request) async { 
  // // Future<Message> createMessage(String username, String content) async { ⭐️
  //   // TODO: Implement createMessage
  //   // Validate request using request.validate()
  //   // Make POST request to '$baseUrl/api/messages'
  //   // Include request.toJson() in body
  //   // Use _handleResponse to parse response
  //   // Extract message from ApiResponse.data

  //   // final req = CreateMessageRequest(username: username, content: content);
  //   final req = request;
  //   final validation = req.validate();
  //   if (validation != null) throw ValidationException(validation);

  //   final uri = Uri.parse('$baseUrl/api/messages');
  //   final resp = await _client
  //       .post(uri, headers: _getHeaders(), body: json.encode(req.toJson()))
  //       .timeout(timeout);
  //   return _handleResponse(resp, (json) {
  //     final wrapper = ApiResponse<Message>.fromJson(json, Message.fromJson);
  //     if (wrapper.data == null) throw ApiException('No message in response');
  //     return wrapper.data!;
  //   });
  // }

  Future<Message> createMessage(CreateMessageRequest request) {
    throw UnimplementedError();
  }

  // Update an existing message
  // Future<Message> updateMessage(int id, UpdateMessageRequest request) async { 
  // // Future<Message> updateMessage(int id, String content) async { ⭐️
  //   // TODO: Implement updateMessage
  //   // Validate request using request.validate()
  //   // Make PUT request to '$baseUrl/api/messages/$id'
  //   // Include request.toJson() in body
  //   // Use _handleResponse to parse response
  //   // Extract message from ApiResponse.data

  //   // final req = UpdateMessageRequest(content: content);
  //   final req = request;
  //   final validation = req.validate();
  //   if (validation != null) throw ValidationException(validation);

  //   final uri = Uri.parse('$baseUrl/api/messages/$id');
  //   final resp = await _client
  //       .put(uri, headers: _getHeaders(), body: json.encode(req.toJson()))
  //       .timeout(timeout);
  //   return _handleResponse(resp, (json) {
  //     final wrapper = ApiResponse<Message>.fromJson(json, Message.fromJson);
  //     if (wrapper.data == null) throw ApiException('No message in response');
  //     return wrapper.data!;
  //   });
  // }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) {
    throw UnimplementedError();
  }

  // Delete a message
  // Future<void> deleteMessage(int id) async {
  //   // TODO: Implement deleteMessage
  //   // Make DELETE request to '$baseUrl/api/messages/$id'
  //   // Check if response.statusCode is 204
  //   // Throw error if deletion failed
  //   final uri = Uri.parse('$baseUrl/api/messages/$id');
  //   final resp = await _client.delete(uri, headers: _getHeaders()).timeout(timeout);
  //   if (resp.statusCode != 204) {
  //     throw ApiException('Failed to delete message ${resp.statusCode}');
  //   }
  // }
  Future<void> deleteMessage(int id) {
    throw UnimplementedError();
  }

  // Get HTTP status information
  // Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
  //   // TODO: Implement getHTTPStatus
  //   // Make GET request to '$baseUrl/api/status/$statusCode'
  //   // Use _handleResponse to parse response
  //   // Extract HTTPStatusResponse from ApiResponse.data
  //   if (statusCode < 100 || statusCode > 599) {
  //     throw ValidationException('Invalid HTTP status code');
  //   }
  //   final uri = Uri.parse('$baseUrl/api/status/$statusCode');
  //   final resp = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
  //   return _handleResponse(resp, (json) {
  //     final wrapper = ApiResponse<HTTPStatusResponse>.fromJson(
  //         json, HTTPStatusResponse.fromJson);
  //     if (wrapper.data == null) throw ApiException('No status data');
  //     // return wrapper.data!.description;
  //     return wrapper.data!;
  //   });
  // }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) {
  throw UnimplementedError();
}

  // Health check
  // Future<Map<String, dynamic>> healthCheck() async {
  //   // TODO: Implement healthCheck
  //   // Make GET request to '$baseUrl/api/health'
  //   // Return decoded JSON response
  //   final uri = Uri.parse('$baseUrl/api/health');
  //   final resp = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
  //   return json.decode(resp.body) as Map<String, dynamic>;
  // }
  Future<Map<String, dynamic>> healthCheck() {
    throw UnimplementedError();
  }
}

// Custom exceptions
class ApiException implements Exception {
  // TODO: Add final String message field
  final String message;
  // TODO: Add constructor ApiException(this.message);
  ApiException(this.message);
  // TODO: Override toString() to return 'ApiException: $message'
  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  // TODO: Add constructor NetworkException(String message) : super(message);
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  // TODO: Add constructor ServerException(String message) : super(message);
  ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  // TODO: Add constructor ValidationException(String message) : super(message);
  ValidationException(String message) : super(message);
}
