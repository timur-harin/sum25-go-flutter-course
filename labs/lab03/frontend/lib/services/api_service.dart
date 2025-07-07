import 'dart:async'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

 
  late http.Client _client;

  
  ApiService({http.Client? client}) : _client = client ?? http.Client();


  void dispose() {
    _client.close();
  }


  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }


  T _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      return fromJson(data['data']);
    } else {
      throw ApiException(data['error'] ?? 'API request failed');
    }
  } else if (response.statusCode >= 400 && response.statusCode < 500) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    throw ApiException(data['error'] ?? 'Client error: ${response.statusCode}');
  } else if (response.statusCode >= 500 && response.statusCode < 600) {
    throw ApiException('Server error: ${response.statusCode}');
  } else {
    throw ApiException('Unexpected status code: ${response.statusCode}');
  }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(
        response,
        (data) => (data as List<dynamic>)
            .map((m) => Message.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out: $e');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

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
      return _handleResponse(
        response,
        (data) => Message.fromJson(data as Map<String, dynamic>),
      );
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out: $e');
    }catch (e) {
      throw NetworkException('Network error: $e');
    }
  }


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
      return _handleResponse(
        response,
        (data) => Message.fromJson(data as Map<String, dynamic>),
      );
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out: $e');
    } catch (e){
      throw NetworkException('Network error: $e');
    }
  }


  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out: $e');
    }catch (e) {
      throw NetworkException('Network error: $e');
    }
  }


  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse(
        response,
        (data) => HTTPStatusResponse.fromJson(data as Map<String, dynamic>),
      );
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out: $e');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }


  Future<Map<String, dynamic>> healthCheck() async {
  try {
    final response = await _client
        .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
        .timeout(timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('success')) {
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw ApiException(data['error'] ?? 'Health check failed');
        }
      } else {
        return data;
      }
    } else {
      throw ApiException('Health check failed: ${response.statusCode}');
    }
  } on TimeoutException catch (e) {
    throw NetworkException('Request timed out: $e');
  } catch (e) {
    throw NetworkException('Network error: $e');
  }
}
}

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