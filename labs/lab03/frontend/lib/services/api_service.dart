import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'dart:io';
import 'dart:async';

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
    return {
      'Content-Type' : 'application/json',
      'Accept' : 'application/json'
    };
  }

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    int statCode = response.statusCode;
    final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
    if (200 <= statCode && statCode <= 299) {
      return fromJson(decodedData);
    } else if (400 <= statCode && statCode <= 499) {
      Map<String, String> error = jsonDecode(response.body);
      throw ValidationException(error['message']!);
    } else if (500 <= statCode && statCode <= 599) {
      Map<String, String> error = jsonDecode(response.body);
      throw ServerException(error['message']!);
    } else {
      Map<String, String> error = jsonDecode(response.body);
      throw ApiException(error['message']!);
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _client.get(
          Uri.parse('$baseUrl/api/messages'),
          headers: _getHeaders()
        ).timeout(timeout);
      
      final apiResponse = _handleResponse<ApiResponse<List<Message>>>(response, 
        (json) => ApiResponse<List<Message>>.fromJson(json, 
          (data) => (data as List).map((msg) => Message.fromJson(msg)).toList())
      );

      if (apiResponse.data == null) {
        throw ApiException("Response is empty");
      }
      return apiResponse.data!;
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    }  
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      final error = request.validate();
      if (error != null) {
        throw ValidationException(error);
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()) 
      ).timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Message>>(response, 
        (json) => ApiResponse<Message>.fromJson(json, 
          (data) => Message.fromJson(data['data']))
      );

      if (apiResponse.data == null) {
        throw ApiException("Response is empty");
      }
      return apiResponse.data!;
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    }     
  } 

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final error = request.validate();
      if (error != null) {
        throw ValidationException(error);
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/messages/$id'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()) 
      ).timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<Message>>(response, 
        (json) => ApiResponse<Message>.fromJson(json, 
          (data) => Message.fromJson(data['data']))
      );

      if (apiResponse.data == null) {
        throw ApiException("Response is empty");
      }
      return apiResponse.data!;
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/api/messages/$id')
        ).timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Not Found');
      }
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/status/$statusCode'),
        headers: _getHeaders()
      ).timeout(timeout);

      final apiResponse = _handleResponse<ApiResponse<HTTPStatusResponse>>(response, 
          (json) => ApiResponse<HTTPStatusResponse>.fromJson(json, 
            (data) => HTTPStatusResponse.fromJson(data['data']))
        );

        if (apiResponse.data == null) {
          throw ApiException("Response is empty");
        }
        return apiResponse.data!;
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    } 
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/health'),
        headers: _getHeaders()
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Health check failed');
      }
      return jsonDecode(response.body);
    } on TimeoutException {
    throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to fetch messages: ${e.toString()}');
    } 
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
