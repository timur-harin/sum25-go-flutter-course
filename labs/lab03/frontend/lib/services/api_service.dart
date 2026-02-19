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

  final bool _shouldDispose;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _shouldDispose = client == null;

  // TODO: Add dispose() method that calls _client.close();
  void dispose() {
    if (_shouldDispose) {
      _client.close();
    }
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
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final decoded = json.decode(response.body);
      final apiResponse = ApiResponse<T>.fromJson(decoded, fromJson);
      if (!apiResponse.success) {
        throw ApiException(apiResponse.error ?? 'Unknown API error');
      }
      return apiResponse.data as T;
    } else if (statusCode >= 400 && statusCode < 500) {
      final decoded = json.decode(response.body);
      final message = decoded['error'] ?? 'Client error';
      throw ValidationException(message);
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected status code: $statusCode');
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

      final Map<String, dynamic> decoded = json.decode(response.body);

      final List<dynamic> data = decoded['data'];

      final messages = data.map((e) => Message.fromJson(e)).toList();

      return messages;
    } catch (e) {
      throw NetworkException('Failed to load messages: $e');
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
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (json) => Message.fromJson(json));
    } catch (e) {
      throw NetworkException('Failed to create message: $e');
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
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      return _handleResponse(response, (json) => Message.fromJson(json));
    } catch (e) {
      throw NetworkException('Failed to update message: $e');
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
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      throw NetworkException('Failed to delete message: $e');
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
      return _handleResponse(response, (json) => HTTPStatusResponse.fromJson(json));
    } catch (e) {
      throw NetworkException('Failed to get HTTP status: $e');
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
      
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'ok') {
        return {'status': 'healthy'};
      }

      return jsonResponse;
    } catch (e) {
      throw NetworkException('Health check failed: $e');
    }
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
