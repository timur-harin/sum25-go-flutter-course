import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
    print('🔧 ApiService initialized with baseUrl: $baseUrl');
  }

  void dispose() {
    print('🔧 ApiService disposing...');
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    print('🔧 Response status: ${response.statusCode}');
    print('🔧 Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = jsonDecode(response.body);
      return fromJson(decodedData);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error');
    } else {
      throw ApiException('Unknown error');
    }
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    final url = '$baseUrl/api/messages';
    print('🔧 GET $url');

    try {
      print('🔧 Making HTTP request to: $url');
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      print('🔧 Response received: ${response.statusCode}');
      print('🔧 Response headers: ${response.headers}');
      print('🔧 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> messageList =
              responseData['data'] as List<dynamic>;
          final messages =
              messageList.map((json) => Message.fromJson(json)).toList();
          print('🔧 Successfully parsed ${messages.length} messages');
          return messages;
        } else {
          final error = responseData['error'] ?? 'Failed to get messages';
          print('🔧 API Error: $error');
          throw ApiException(error);
        }
      } else {
        print('🔧 HTTP Error: ${response.statusCode}');
        throw ApiException('Failed to get messages');
      }
    } on SocketException catch (e) {
      print('🔧 SocketException: $e');
      throw NetworkException('No internet connection: $e');
    } on http.ClientException catch (e) {
      print('🔧 ClientException: $e');
      throw NetworkException('Network error: $e');
    } catch (e) {
      print('🔧 Unexpected error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body),
          (json) => Message.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data as Message;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to create message');
        }
      } else {
        throw ApiException('Failed to create message');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body),
          (json) => Message.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data as Message;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to update message');
        }
      } else if (response.statusCode == 404) {
        throw ApiException('message not found');
      } else {
        throw ApiException('Failed to update message');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 204) {
        // Successfully deleted
        return;
      } else if (response.statusCode == 404) {
        throw ApiException('Failed to delete message');
      } else {
        throw ApiException('Failed to delete message');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body),
          (json) => HTTPStatusResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data as HTTPStatusResponse;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
        }
      } else {
        throw ApiException('Client error');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Network error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
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
