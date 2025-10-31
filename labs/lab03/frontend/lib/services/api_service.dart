import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final apiResponse = ApiResponse.fromJson(jsonBody, fromJson);
      if (apiResponse.success) {
        if (apiResponse.data != null) {
          return apiResponse.data as T;
        } else {
          throw ApiException('Empty response data');
        }
      } else {
        throw ApiException(apiResponse.error ?? 'Unknown API error');
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.body}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error');
    } else {
      throw ApiException('Unexpected response: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    throw UnimplementedError('TODO: Implement getMessages');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement createMessage');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError('TODO: Implement getHTTPStatus');
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('TODO: Implement healthCheck');
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