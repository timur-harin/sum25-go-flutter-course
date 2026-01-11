import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field

  // TODO: Add constructor that initializes _client = http.Client();

  // TODO: Add dispose() method that calls _client.close();

  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'

  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
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
    T Function(Map<String, dynamic>) fromJson
  ) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final data = json.decode(response.body);
      return fromJson(data); 
    }
    else if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException('Client error: ${response.statusCode}'); 
    }
    else if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ServerException('Server error ${response.statusCode}'); 
    }
    else {
      throw ApiException('Unexpected error ${response.statusCode}'); 
    }
  }

  List<Message> parseListMessages(jsonData) {
    final data = jsonData['data'];
    if (data == null) {
      return [];
    }
    List<Message> messagesList = [];
    
    for (var message in data) {
      messagesList.add(Message.fromJson(message));
    }
    return messagesList;
  }  

  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    // Make GET request to '$baseUrl/api/messages'
    // Use _handleResponse to parse response into List<Message>
    // Handle network errors and timeouts
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'))
          .timeout(timeout);
      
      return _handleResponse<List<Message>>(
      response,
      parseListMessages
    );
    } catch (e) {
      throw NetworkException('Failed to get messages: ${e.toString()}');
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
    final error = request.validate();
    if (error != null) {
      throw ValidationException(error);
    }
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/api/messages"),
        headers: _getHeaders(),
        body: json.encode(request.toJson())
      ).timeout(timeout);
      
      final apiResp = _handleResponse<Message>(
        response, 
        (json) => Message.fromJson(json['data'])
      );
      return apiResp;
    } catch (e) {
      throw NetworkException('Failed to create message: ${e.toString()}');
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
    final error = request.validate();
    if (error != null) { 
      throw ValidationException(error);
    }
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/messages/$id'),
        headers: _getHeaders(), 
        body: json.encode(request.toJson())
      ).timeout(timeout);

      return _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data']),
      );

    } catch (e) {
      throw NetworkException('Failed to update message: ${e.toString()}');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    try {
      final response = await _client.delete(Uri.parse("$baseUrl/api/messages/$id")).timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      throw NetworkException('Failed to update message: ${e.toString()}');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'))
          .timeout(timeout);
      
      final decodedData = json.decode(response.body);
      return HTTPStatusResponse.fromJson(decodedData['data']);
    } catch (e) {
      throw NetworkException('Failed to get HTTP status: ${e.toString()}');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/health'
    // Return decoded JSON response
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(timeout);
      return json.decode(response.body)['data'];
    } catch (e) {
      throw NetworkException('Failed to perform health check: ${e.toString()}');
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
  String toString() {
    return "ApiException: $message";
  }
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
