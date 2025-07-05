import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'dart:convert';
class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field
  late final http.Client _client;

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
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
) {
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
 if (response.statusCode >= 200 && response.statusCode <= 299) {
      final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse<T>.fromJson(decodedData, fromJson);
    }
  // If 400-499, throw client error with message from response
  else if (response.statusCode >= 400 && response.statusCode <= 499) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = json['error'] as String? ?? 'Client error: ${response.statusCode}';
      throw ValidationException(errorMessage);
    }
  // If 500-599, throw server error
 else if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ServerException('Server error: ${response.statusCode}');
    }
  // For other status codes, throw general error
 else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
}
  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
  
    
    // Handle network errors and timeouts
    try {
    final response = await _client
    // Make GET request to '$baseUrl/api/messages'
        .get(
          Uri.parse('$baseUrl/api/messages'),
          headers: _getHeaders(),
        )
        .timeout(timeout);
        // Use _handleResponse to parse response into List<Message>
    final apiResponse = _handleResponse<List<Message>>(
      response,
      (data) => (data as List<dynamic>)
          .map((item) => Message.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(apiResponse.error ?? 'Failed to fetch messages');
    }
    return apiResponse.data!;
  } catch (e) {
    throw NetworkException('Failed to fetch messages: $e');
  }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    // TODO: Implement createMessage
    
    // Validate request using request.validate()
    final validationError = request.validate();
  if (validationError != null) {
    throw ValidationException(validationError);
  }

  try {
    final response = await _client
     // Make POST request to '$baseUrl/api/messages'
        .post(
          Uri.parse('$baseUrl/api/messages'),
          headers: _getHeaders(),
          // Include request.toJson() in body
          body: jsonEncode(request.toJson()),
        )
        .timeout(timeout);
        // Use _handleResponse to parse response
    final apiResponse = _handleResponse<Message>(
        response,
        (data) => Message.fromJson(data as Map<String, dynamic>), 
      );
    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(apiResponse.error ?? 'Failed to create message');
    }
    // Extract message from ApiResponse.data
    return apiResponse.data!;
  } catch (e) {
    throw NetworkException('Failed to create message: $e');
  }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // TODO: Implement updateMessage

    // Validate request using request.validate()
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
      // Make PUT request to '$baseUrl/api/messages/$id'
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
             // Include request.toJson() in body
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);
          // Use _handleResponse to parse response
      final apiResponse = _handleResponse<Message>(
        response,
        (data) => Message.fromJson(data as Map<String, dynamic>), 
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(apiResponse.error ?? 'Failed to update message');
      }
      // Extract message from ApiResponse.data
      return apiResponse.data!;
    } catch (e) {
      throw NetworkException('Failed to update message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
   
    try {
    final response = await _client
    // Make DELETE request to '$baseUrl/api/messages/$id'
        .delete(
          Uri.parse('$baseUrl/api/messages/$id'),
          headers: _getHeaders(),
        )
        .timeout(timeout);
         // Check if response.statusCode is 204
    if (response.statusCode != 204) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = json['error'] as String? ?? 'Failed to delete message: ${response.statusCode}';
       // Throw error if deletion failed
      throw ApiException(errorMessage);
    }
  } catch (e) {
    throw NetworkException('Failed to delete message: $e');
  }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // TODO: Implement getHTTPStatus
    try {
    final response = await _client
    // Make GET request to '$baseUrl/api/status/$statusCode'
        .get(
          Uri.parse('$baseUrl/api/status/$statusCode'),
          headers: _getHeaders(),
        )
        .timeout(timeout);
        // Use _handleResponse to parse response
    final apiResponse = _handleResponse<HTTPStatusResponse>(
        response,
        (data) => HTTPStatusResponse.fromJson(data as Map<String, dynamic>), // Явно приводим к Map
      );
    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(apiResponse.error ?? 'Failed to fetch HTTP status');
    }
    // Extract HTTPStatusResponse from ApiResponse.data
    return apiResponse.data!;
  } catch (e) {
    throw NetworkException('Failed to fetch HTTP status: $e');
  }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
   try {
    final response = await _client
     // Make GET request to '$baseUrl/api/health'
        .get(
          Uri.parse('$baseUrl/api/health'),
          headers: _getHeaders(),
        )
        .timeout(timeout);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final errorMessage = json['error'] as String? ?? 'Health check failed: ${response.statusCode}';
      throw ApiException(errorMessage);
    }
    // Return decoded JSON response
    return json;
  } catch (e) {
    throw NetworkException('Failed to perform health check: $e');
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
