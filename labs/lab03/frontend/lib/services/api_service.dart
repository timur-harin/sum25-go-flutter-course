import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
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
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw NetworkException('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (json) => ApiResponse<List<dynamic>>.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final messagesData = apiResponse.data as List<dynamic>;
        return messagesData
            .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to load messages');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
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

      final apiResponse = _handleResponse(
        response,
        (json) => ApiResponse<Map<String, dynamic>>.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return Message.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to create message');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
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
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (json) => ApiResponse<Map<String, dynamic>>.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return Message.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to update message');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      final apiResponse = _handleResponse(
        response,
        (json) => ApiResponse<Map<String, dynamic>>.fromJson(json, null),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return HTTPStatusResponse.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Health check failed: $e');
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
