import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // TODO: Add dispose() method that calls _client.close();
  void dispose() {
    _client.close();
  }

  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  // TODO: Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    // Check if response.statusCode is between 200-299
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // If successful, decode JSON and return fromJson(decodedData)
      final decodedData = jsonDecode(response.body);
      return fromJson(decodedData);
    } 
    // If 400-499, throw client error with message from response
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ClientException('${response.statusCode}');
    }
    // If 500-599, throw server error
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ServerException('${response.statusCode}');
    }
    // For other status codes, throw general error
    throw ApiException('${response.statusCode}');
  }
 


  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
    // Handle network errors and timeouts
      final url = Uri.parse('$baseUrl/api/messages');

      // Make GET request to '$baseUrl/api/messages'
      final response = await _client.get(url, headers: _getHeaders()).timeout(timeout);

      // Use _handleResponse to parse response into List<Message>
      return _handleResponse(response, (Map<String, dynamic> resp_data) {
        List<Message> messages = [];
        if (resp_data['data'] == null) {
          return messages;
        }
        final data = resp_data['data'] as List;
        for (var msg in data) {
          messages.add(Message.fromJson(msg));
        }
        return messages;
      });
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    // Validate request using request.validate()
    final err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }

    // Make POST request to '$baseUrl/api/messages'
    final url = Uri.parse('$baseUrl/api/messages');
    final response = await _client.post(url, headers: _getHeaders(), body: json.encode(request.toJson())).timeout(timeout);

    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    return _handleResponse(response, (Map<String, dynamic> resp_data) {
      ApiResponse apiResponse = ApiResponse<Message>.fromJson(resp_data, Message.fromJson);
      return apiResponse.data;
    });
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // Validate request using request.validate()
    final err = request.validate();
    if (err != null) {
      throw ValidationException(err);
    }

    // Make PUT request to '$baseUrl/api/messages/$id'
    // Include request.toJson() in body
    final url = Uri.parse('$baseUrl/api/messages/$id');
    final response = await _client.put(url, headers: _getHeaders(), body: json.encode(request.toJson())).timeout(timeout);

    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    return _handleResponse(response, (Map<String, dynamic> resp_data) {
      ApiResponse apiResponse = ApiResponse<Message>.fromJson(resp_data, Message.fromJson);
      return apiResponse.data;
    });
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // Make DELETE request to '$baseUrl/api/messages/$id'
    final url = Uri.parse('$baseUrl/api/messages/$id');
    final response = await _client.delete(url, headers: _getHeaders()).timeout(timeout);

    // Check if response.statusCode is 204
    if (response.statusCode != 204) {
      // Throw error if deletion failed
      throw ServerException('${response.statusCode}');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      // Make GET request to '$baseUrl/api/status/$statusCode'
      final url = Uri.parse('$baseUrl/api/status/$statusCode');
      final response = await _client.get(url, headers: _getHeaders()).timeout(timeout);

      // Use _handleResponse to parse response
      // Extract HTTPStatusResponse from ApiResponse.data
      return _handleResponse(response, (Map<String, dynamic> resp_data) {
        ApiResponse apiResponse = ApiResponse<HTTPStatusResponse>.fromJson(resp_data, HTTPStatusResponse.fromJson);
        return apiResponse.data;
      });
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // Make GET request to '$baseUrl/api/health'
    final url = Uri.parse('$baseUrl/api/health');
    final response = await _client.get(url, headers: _getHeaders()).timeout(timeout);

    // Return decoded JSON response
    if (response.statusCode != 200) {
      throw ServerException('${response.statusCode}');
    }
    final data = jsonDecode(response.body)["data"] as Map<String, dynamic>;
    return data;
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() {
    return 'ApiException: $message';
  }
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
class ClientException extends ApiException {
  ClientException(String message) : super(message);
}
