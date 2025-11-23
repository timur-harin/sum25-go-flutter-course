import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../models/message.dart';
import 'dart:io';
import 'dart:async';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  late http.Client _client;

  // TODO: Add constructor that initializes _client = http.Client();

  // TODO: Add dispose() method that calls _client.close();

  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
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

  // TODO: Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
  // If 400-499, throw client error with message from response
  // If 500-599, throw server error
  // For other status codes, throw general error
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      final decoded = json.decode(response.body);
      return fromJson(decoded);
    } else if (status >= 400 && status < 500) {
      try {
        final error = json.decode(response.body);
        throw ApiException(error['error'] ?? 'Client error');
      } catch (_) {
        throw ApiException('Client error: $status');
      }
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error: $status');
    } else {
      throw ApiException('Unexpected error: $status');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {

/*     assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'];
      return data.map((e) => Message.fromJson(e)).toList();
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {

   /*  assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement createMessage
    // Validate request using request.validate()
    // Make POST request to '$baseUrl/api/messages'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
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

      final apiResp = _handleResponse(
        response,
        (json) => ApiResponse<Message>.fromJson(json, Message.fromJson),
      );
      return apiResp.data!;
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {

   /*  assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement updateMessage
    // Validate request using request.validate()
    // Make PUT request to '$baseUrl/api/messages/$id'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
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

      final apiResp = _handleResponse(
        response,
        (json) => ApiResponse<Message>.fromJson(json, Message.fromJson),
      );
      return apiResp.data!;
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {

    /* assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {

    /* assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    if (statusCode < 100 || statusCode >= 600) {
      throw ApiException('Invalid status code');
    }

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      final apiResp = _handleResponse(
        response,
        (json) => ApiResponse<HTTPStatusResponse>.fromJson(json, HTTPStatusResponse.fromJson),
      );
      return apiResp.data!;
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {

    /* assert(() {
      throw UnimplementedError('getMessages is not implemented for test');
    }()); */

    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      return json.decode(response.body);
    } on SocketException {
      throw NetworkException('Network error');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  // TODO: Add final String message field
  // TODO: Add constructor ApiException(this.message);
  // TODO: Override toString() to return 'ApiException: $message'
  final String message;
  ApiException(this.message);

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
