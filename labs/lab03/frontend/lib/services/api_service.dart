import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/mock_client.dart';
import '../models/message.dart';

class ApiService {
  // Add static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'http://localhost:8080';
  // Add static const Duration timeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);
  // Add late http.Client _client field
  late http.Client _client;

  // Add constructor that initializes _client = http.Client();
  // ApiService() : _client = http.Client();
  ApiService({MockClient? client}) {
    if (client != null) {
      _client = client;
    }
    else {
      _client = http.Client();
    }
  }
  // Add dispose() method that calls _client.close();
  void dispose() {
    _client.close();
  }

  // Add _getHeaders() method that returns Map<String, String>
  Map<String, String> _getHeaders() {
    // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
    Future<T> _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) async {
      // Check if response.statusCode is between 200-299
      if ((response.statusCode >= 200) && (response.statusCode < 300)) {
        // If successful, decode JSON and return fromJson(decodedData)
        final decoded = jsonDecode(response.body);
        // Handle both direct responses and ApiResponse wrapper
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return fromJson(decoded['data']);
        }
        return fromJson(decoded);
      } else if ((response.statusCode >= 400) && (response.statusCode < 500)) {
        // If 400-499, throw client error with message from response
        final decoded = jsonDecode(response.body);
        throw ApiException(decoded['error'] ?? 'Client error occurred');
      } else if ((response.statusCode >= 500) && (response.statusCode < 600)) {
        // If 500-599, throw server error
        throw ServerException('Server error occurred');
      } else {
        // For other status codes, throw general error
        throw ApiException('Unknown error occurred');
      }
    }

  // Get all messages
  Future<List<Message>> getMessages() async {
    // Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    final uri = Uri.parse('$baseUrl/api/messages');
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    final response = await _client
      .get(uri, headers: _getHeaders())
      .timeout(timeout);
    
    return _handleResponse(response, (data) {
      final List<dynamic> msgs = data['data'];
      return msgs.map((json) => Message.fromJson(json)).toList();
    });
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    // Implement createMessage
    // Validate request using request.validate()
    String? err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }
    // Make POST request to '$baseUrl/api/messages'
    // Include request.toJson() in body
    final response = await _client.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: _getHeaders(),
      body: jsonEncode(request)
    ).timeout(timeout);
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    return _handleResponse(response, (data) => Message.fromJson(data['data']));
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // Implement updateMessage
    // Validate request using request.validate()
    String? err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }
    // Make PUT request to '$baseUrl/api/messages/$id'
    // Include request.toJson() in body
    final response = await _client.put(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: _getHeaders(),
      body: jsonEncode(request)
    ).timeout(timeout);
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    return _handleResponse(response, (data) => Message.fromJson(data['data']));
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: _getHeaders(),
    ).timeout(timeout);
    // Check if response.statusCode is 204
    if (response.statusCode != 204) {
      // Throw error if deletion failed
      throw ApiException("Failed to delete message");
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    final response = await _client.get(
      Uri.parse('$baseUrl/api/status/$statusCode'),
      headers: _getHeaders(),
    ).timeout(timeout);
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    return _handleResponse(response, (data) => HTTPStatusResponse.fromJson(data));
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    final response = await _client.get(
    Uri.parse('$baseUrl/api/health'),
    headers: _getHeaders(),
  ).timeout(timeout);
    // Return decoded JSON response
    return _handleResponse(response, (data) => data);
  }
}

// Custom exceptions
class ApiException implements Exception {
  // Add final String message field
  final String message;
  // Add constructor ApiException(this.message);
  ApiException(this.message);
  // Override toString() to return 'ApiException: $message'
  @override
  String toString() {
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  // Add constructor NetworkException(String message) : super(message);
  NetworkException(super.message);
}

class ServerException extends ApiException {
  // Add constructor ServerException(String message) : super(message);
  ServerException(super.message);
}

class ValidationException extends ApiException {
  // Add constructor ValidationException(String message) : super(message);
  ValidationException(super.message);
}
