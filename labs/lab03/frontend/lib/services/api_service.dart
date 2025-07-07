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
  void dispose(){
    _client.close();
  }
  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
  Map<String, String> _getHeaders(){
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
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson){
    int stCode = response.statusCode;
    if(stCode >= 200 && stCode <= 299){
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      return fromJson(jsonDecode(response.body));
    } else if(stCode >= 400 && stCode <= 499){
      throw http.ClientException('${response.statusCode}');
    } else if(stCode >= 500 && stCode <= 599){
      throw ApiException(stCode.toString());
    } else{
      throw Error();
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return _handleResponse<List<Message>>(
          response,
            (json) => (json['data'] as List).map((item) => Message.fromJson(item)).toList(),
        );
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
  } catch (e) {
      throw NetworkException(e.toString());
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
    // request.validate();
    // final response = await _client.post(
    //   Uri.parse('$baseUrl/api/messages'),
    //   body: jsonEncode(request.toJson()),
    //   headers: _getHeaders(),
    // );
    // return _handleResponse<Message>(
    //   response,
    //     (json) => Message.fromJson(json['data']),
    // );
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // TODO: Implement updateMessage
    // Validate request using request.validate()
    // Make PUT request to '$baseUrl/api/messages/$id'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    // request.validate();
    // final response = await _client.put(
    //   Uri.parse('$baseUrl/api/messages/$id'),
    //   body: jsonEncode(request.toJson()),
    //   headers: _getHeaders(),
    // );
    // return _handleResponse(
    //   response,
    //     (json) => Message.fromJson(json['data']),
    // );
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    // final response = await _client.delete(
    //     Uri.parse('$baseUrl/api/messages/$id'),
    //   headers: _getHeaders(),
    // );
    // if (response.statusCode != 204) {
    //   throw Exception('Failed to delete message');
    // }
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/status/$statusCode'),
        headers: _getHeaders(),
      );
      return _handleResponse(
        response,
            (json) => HTTPStatusResponse.fromJson(json['data']),
      );
    } catch(_){
    throw UnimplementedError('TODO: Implement getHTTPStatus');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/health'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch(_) {
      throw UnimplementedError('TODO: Implement healthCheck');
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
  NetworkException(super.message);
}

class ServerException extends ApiException {
  // TODO: Add constructor ServerException(String message) : super(message);
  ServerException(super.message);
}

class ValidationException extends ApiException {
  // TODO: Add constructor ValidationException(String message) : super(message);
  ValidationException(super.message);
}
