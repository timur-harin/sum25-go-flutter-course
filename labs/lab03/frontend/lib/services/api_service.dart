    import 'dart:convert';
    import 'package:http/http.dart' as http;
    import '../models/message.dart';
    import 'dart:io';       // For SocketException
    import 'dart:async';    // For TimeoutException
    import 'package:http/testing.dart';

    class ApiService {
      // TODO: Add static const String baseUrl = 'http://localhost:8080';
      // TODO: Add static const Duration timeout = Duration(seconds: 30);
      // TODO: Add late http.Client _client field
      static const String baseUrl = 'http://localhost:8080';
      static const Duration timeout = Duration(seconds: 30);
      late http.Client _client;
      // TODO: Add constructor that initializes _client = http.Client();
       ApiService({http.Client? client})
      : _client = client ?? http.Client();
      // TODO: Add dispose() method that calls _client.close();
      void dispose() {
        _client.close();
      }
      // TODO: Add _getHeaders() method that returns Map<String, String>
      // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
      Map<String, String> _getHeaders() {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        return headers;
      }
      // TODO: Add _handleResponse<T>() method with parameters:
      // http.Response response, T Function(Map<String, dynamic>) fromJson
      // Check if response.statusCode is between 200-299
      // If successful, decode JSON and return fromJson(decodedData)
      // If 400-499, throw client error with message from response
      // If 500-599, throw server error
      // For other status codes, throw general error
      T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
        final int statusCode = response.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return fromJson(data);
        } else if(statusCode >= 400 && statusCode <= 499) {
          throw ApiException('Client error occurred');
        } else if(statusCode >= 500 && statusCode <= 599) {
          throw ServerException('Server error occurred');
        } else {
          throw ServerException('Unexpected server response');
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
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );
        
          final apiResponse = _handleResponse<ApiResponse<List<Message>>> (
            response,
          (json) => ApiResponse<List<Message>>(
            success: json['success'],
            data: (json['data'] as List)
                .map((item) => Message.fromJson(item))
                .toList(),
            error: json['error'],
          ), // converts json object to the list
          );
          if (!apiResponse.success || apiResponse.data == null) {
          throw ApiException(apiResponse.error ?? 'Unknown error');
        }
          return apiResponse.data!;
        } on SocketException {
          throw NetworkException('No internet connection');
        } on TimeoutException {
            throw NetworkException('Request timed out');
        } catch(e) {
            throw ApiException('Unexpected error: $e'); // Let higher-level logic handle the exception
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
          final response = await _client.post(
            Uri.parse('$baseUrl/api/messages'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          );
          final apiResponse = _handleResponse<ApiResponse<Message>> (
              response,
            (json) => ApiResponse<Message>(
              success: json['success'],
              data: Message.fromJson(json['data']),
              error: json['error'],
            ), // converts json object to the list
          );
          return apiResponse.data!;
        } on SocketException {
          throw NetworkException('No internet connection');
        } on TimeoutException {
            throw NetworkException('Request timed out');
        } catch(e) {
            throw ApiException('Unexpected error: $e'); // Let higher-level logic handle the exception
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
        if (request.content.trim().isEmpty) {
          throw ApiException('Content is required');
        }
        final validationError = request.validate();
        if (validationError != null) {
          throw ValidationException(validationError);
        }
        try {
          final response = await _client.put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          );
          final apiResponse = _handleResponse<ApiResponse<Message>> (
              response,
            (json) => ApiResponse<Message>(
              success: json['success'],
              data: Message.fromJson(json['data']),
              error: json['error'],
            ), // converts json object to the list
          );
          return apiResponse.data!;
        } on SocketException {
          throw NetworkException('No internet connection');
        } on TimeoutException {
            throw NetworkException('Request timed out');
        } catch(e) {
          throw ApiException('Client error occurred');
        }
      }

      // Delete a message
    Future<void> deleteMessage(int id) async {
  try {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Only consider 204 (No Content) or 200 (OK) as success
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final json = jsonDecode(response.body);
        throw ApiException(json['error'] ?? 'Failed to delete message');
      } catch (_) {
        throw ApiException('Failed to delete message');
      }
    }
  } on SocketException {
    throw NetworkException('No internet connection');
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
            final response = await _client.get(
              Uri.parse('$baseUrl/api/status/$statusCode'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );
            final apiResponse = _handleResponse<ApiResponse<HTTPStatusResponse>> (
                response,
              (json) => ApiResponse<HTTPStatusResponse>(
                success: json['success'],
                data: HTTPStatusResponse.fromJson(json['data']),
                error: json['error'],
              ), // converts json object to the list
            );
            return apiResponse.data!;
          } catch(e) {
          throw ApiException('Client error occurred'); 
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
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );
          if (response.statusCode != 200) {
          throw ServerException('Health check failed');
        }
        return jsonDecode(response.body) as Map<String, dynamic>; // converts the raw JSON string into a Dart object 
        } on SocketException { // occurs when a network connection fails
          throw NetworkException('No internet connection');
        } on TimeoutException { // the request takes too long to complete or the server is very slow or not responding at all
            throw NetworkException('Request timed out');
        } catch(e) {
          throw ApiException('Client error occurred');
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
