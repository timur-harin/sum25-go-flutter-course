import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lab03_frontend/models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  void dispose() => client.close();

  Map<String, String> _getHeaders() =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final json = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(json);
    } else {
      final errorMsg =
          json['error'] ?? 'Request failed with status ${response.statusCode}';
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw NetworkException(errorMsg);
      } else if (response.statusCode >= 500) {
        throw ServerException(errorMsg);
      }
      throw ApiException(errorMsg);
    }
  }

  Never _handleNetworkError(Object e) {
    if (e is SocketException) {
      throw NetworkException('No internet connection');
    } else if (e is TimeoutException) {
      throw NetworkException('Request timed out');
    } else {
      throw ApiException('Failed to complete request: ${e.toString()}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response =
          await client.get(Uri.parse('$baseUrl/api/messages')).timeout(timeout);

      final json = jsonDecode(response.body);

      if (json is Map<String, dynamic> &&
          json['data'] == null &&
          json['success'] == true) {
        return [];
      } else if (json is List) {
        return json.map((e) => Message.fromJson(e)).toList();
      } else if (json is Map<String, dynamic> && json['data'] is List) {
        return (json['data'] as List).map((e) => Message.fromJson(e)).toList();
      } else {
        throw ApiException('Unexpected response format: ${response.body}');
      }
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    try {
      print('Sending request: ${request.toJson()}');

      final response = await client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            body: jsonEncode(request.toJson()),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      print('Raw response: ${response.body}');

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['success'] != true) {
        throw ApiException(json['error'] ?? 'Unknown error');
      }

      final data = json['data'];
      if (data == null) {
        throw ApiException('Server returned null data');
      }

      try {
        return Message.fromJson(data as Map<String, dynamic>);
      } catch (e) {
        throw ApiException('Invalid message format: ${e.toString()}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException('Failed to create message: ${e.toString()}');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      print('Updating message $id with: ${request.toJson()}');

      final response = await client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            body: jsonEncode(request.toJson()),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      print('Update response: ${response.body}');

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['success'] != true) {
        throw ApiException(json['error'] ?? 'Update failed');
      }

      final data = json['data'];
      if (data == null) {
        throw ApiException('Server returned null data after update');
      }

      try {
        return Message.fromJson(data as Map<String, dynamic>);
      } catch (e) {
        throw ApiException('Invalid updated message format: ${e.toString()}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      throw ApiException('Failed to update message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await client
          .delete(Uri.parse('$baseUrl/api/messages/$id'))
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body)?['error'] ??
            'Failed to delete message: ${response.statusCode}';
        throw ApiException(error);
      }
    } catch (e) {
      throw ApiException('Failed to delete message: ${e.toString()}');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'))
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body)?['error'] ??
            'Request failed with status ${response.statusCode}';
        throw ApiException(error);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Для тестового окружения
      if (json['data'] == null && json['status_code'] == null) {
        return HTTPStatusResponse(
          statusCode: statusCode,
          imageUrl: 'https://http.cat/$statusCode.jpg',
          description: getDescriptionForStatus(statusCode),
        );
      }

      return HTTPStatusResponse.fromJson(json['data'] ?? json);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('No internet connection');
      } else if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else {
        throw ApiException('Failed to get HTTP status: ${e.toString()}');
      }
    }
  }

  String getDescriptionForStatus(int code) {
    switch (code) {
      case 200:
        return 'OK';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Status $code';
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response =
          await client.get(Uri.parse('$baseUrl/api/health')).timeout(timeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (json['data'] != null) {
          return json['data'] as Map<String, dynamic>;
        } else {
          return json;
        }
      } else {
        final errorMsg = json['error'] ??
            'Health check failed with status ${response.statusCode}';
        throw ApiException(errorMsg);
      }
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('No internet connection');
      } else if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else {
        throw ApiException('Failed to perform health check: ${e.toString()}');
      }
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
