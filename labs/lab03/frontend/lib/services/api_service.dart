import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field

  // TODO: Add constructor that initializes _client = http.Client();

  // TODO: Add dispose() method that calls _client.close();

  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'

  // TODO: Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
  // If 400-499, throw client error with message from response
  // If 500-599, throw server error
  // For other status codes, throw general error
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
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      return fromJson(decodedData);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ValidationException('Client error: ${response.body}');
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected status code: ${response.statusCode}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    try {
      final uri = Uri.parse('$baseUrl/api/messages');
      final response =
          await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      final body = json.decode(response.body);
      if (body is List) {
        return body.map((e) => Message.fromJson(e)).toList();
      }
      final apiResponse = _handleResponse<ApiResponse<List<Message>>>(
        response,
        (json) => ApiResponse<List<Message>>.fromJson(
          json,
          (data) => (data as List<dynamic>)
              .map((item) => Message.fromJson(item))
              .toList(),
        ),
      );

      if (apiResponse.data == null) {
        throw ApiException('Missing message list in response');
      }

      return apiResponse.data!;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on FormatException {
      throw ApiException('Invalid JSON format');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final uri = Uri.parse('$baseUrl/api/messages');
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);

        if (body is Map<String, dynamic> && body.containsKey('data')) {
          final apiResponse = ApiResponse<Message>.fromJson(
            body,
            (data) => Message.fromJson(data),
          );
          if (apiResponse.data != null) {
            return apiResponse.data!;
          }
        } else if (body is Map<String, dynamic>) {
          return Message.fromJson(body);
        }

        throw ApiException('Invalid response format: ${response.body}');
      } else {
        _handleResponse<ApiResponse<Message>>(
          response,
          (json) => ApiResponse<Message>.fromJson(
            json,
            (data) => Message.fromJson(data),
          ),
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on FormatException {
      throw ApiException('Invalid JSON format');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }

    throw ApiException('Unexpected error');
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
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
      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Message>>(
        response,
        (json) => ApiResponse<Message>.fromJson(
          json,
          (data) => Message.fromJson(data),
        ),
      );

      if (apiResponse.data == null) {
        throw ApiException('Missing message in response');
      }

      return apiResponse.data!;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on FormatException {
      throw ApiException('Invalid JSON format');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    try {
      final uri = Uri.parse('$baseUrl/api/messages/$id');
      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException(
          'Failed to delete message. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    try {
      final uri = Uri.parse('$baseUrl/api/status/$statusCode');
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<HTTPStatusResponse>>(
        response,
        (json) => ApiResponse<HTTPStatusResponse>.fromJson(
          json,
          (data) => HTTPStatusResponse.fromJson(data),
        ),
      );

      if (apiResponse.data == null) {
        throw ApiException('Missing status data in response');
      }

      return apiResponse.data!;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on FormatException {
      throw ApiException('Invalid JSON format');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Health check failed. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on FormatException {
      throw ApiException('Invalid JSON format');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
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
