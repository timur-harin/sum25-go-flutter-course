import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
  }

  dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {'Accept': 'application/json'};
  }

  T _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final data = json.decode(response.body);
      final message = data['error'] ?? 'Client error';
      throw ApiException(message);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Error: ${response.statusCode}');
    } else {
      throw Exception("Error");
    }
  }

  // TODO: Add _handleResponse<T>() method with parameters:
  //
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
  // If 400-499, throw client error with message from response
  // If 500-599, throw server error
  // For other status codes, throw general error

  // Get all messages
  Future<List<Message>> getMessages() async {
    String url = '$baseUrl/api/messages';
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(timeout);
      return await _handleResponse(response, (data) {
        if (data is List) {
          return (data as List<dynamic>)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(data, null);
          return (apiResponse.data as List<dynamic>)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: ${e.toString()}');
    }
    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    String url = '$baseUrl/api/messages';
    try {
      final response = await _client.post(Uri.parse(url),
          headers: _getHeaders(), body: jsonEncode(request.toJson()));

      return await _handleResponse<Message>(
        response,
        (data) => Message.fromJson(data['data']),
      );
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: ${e.toString()}');
    }
    // TODO: Implement createMessage
    // Validate request using request.validate()
    // Make POST request to
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    String url = '$baseUrl/api/messages/$id';
    try {
      final response = await _client
          .put(Uri.parse(url),
              headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);

      return _handleResponse<Message>(
        response,
        (data) => Message.fromJson(data['data']),
      );
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: ${e.toString()}');
    }
    // TODO: Implement updateMessage
    // Validate request using request.validate()
    // Make PUT request to '$baseUrl/api/messages/$id'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    String url = '$baseUrl/api/messages/$id';
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException("Error");
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: ${e.toString()}');
    }
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    final String url = '$baseUrl/api/status/$statusCode';

    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException('Invalid status code: $statusCode');
    }

    try {
      // Make GET request
      final response = await _client
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (data) {
        if (data.containsKey('status_code')) {
          return HTTPStatusResponse.fromJson(data);
        } else if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse =
              ApiResponse<Map<String, dynamic>>.fromJson(data, (d) => d);
          return HTTPStatusResponse.fromJson(apiResponse.data!);
        } else {
          throw ApiException('Unexpected response format');
        }
      });
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: $e');
    }
    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    const String url = '$baseUrl/api/health';
    try {
      // Make GET request
      final response = await _client
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(timeout);
      return jsonDecode(response.body);
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw NetworkException('Failed to fetch HTTP status: ${e.toString()}');
    }
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return message;
  }
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
