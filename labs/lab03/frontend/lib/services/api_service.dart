import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) fromJson,
  ) async {
    final statusCode = response.statusCode;
    try {
      if (statusCode >= 200 && statusCode < 300) {
        final dynamic decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;

        if (decoded == null) {
          throw ApiException('Empty response body');
        }

        return fromJson(decoded);
      } else if (statusCode >= 400 && statusCode < 500) {
        throw NetworkException('Client error: ${response.body}');
      } else if (statusCode >= 500 && statusCode < 600) {
        throw ServerException('Server error: ${response.body}');
      } else {
        throw ApiException('Unexpected status code: $statusCode');
      }
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON format: ${e.message}');
    }
  }

  Future<List<Message>> getMessages() async {
    final uri = Uri.parse('$baseUrl/api/messages');
    try {
      final response = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      return _handleResponse<List<Message>>(response, (json) {
        if (json is List) {
          return json.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
        } else if (json is Map<String, dynamic>) {
          final apiResp = ApiResponse<List<Message>>.fromJson(
            json,
            (data) {
              final list = data as List<dynamic>? ?? [];
              return list.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
            },
          );
          if (apiResp.success && apiResp.data != null) {
            return apiResp.data!;
          }
          throw ApiException(apiResp.error ?? 'Failed to load messages');
        } else {
          throw ApiException('Unexpected JSON format for messages');
        }
      });
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    final uri = Uri.parse('$baseUrl/api/messages');
    final body = jsonEncode(request.toJson());
    try {
      final response = await _client.post(uri, headers: _getHeaders(), body: body).timeout(timeout);
      return _handleResponse<Message>(response, (json) {
        if (json is Map<String, dynamic>) {
          final apiResp = ApiResponse<Message>.fromJson(
            json,
            (data) => Message.fromJson(data as Map<String, dynamic>),
          );
          if (apiResp.success && apiResp.data != null) {
            return apiResp.data!;
          }
          throw ApiException(apiResp.error ?? 'Failed to create message');
        }
        throw ApiException('Unexpected JSON format for createMessage');
      });
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    final uri = Uri.parse('$baseUrl/api/messages/$id');
    final body = jsonEncode(request.toJson());
    try {
      final response = await _client.put(uri, headers: _getHeaders(), body: body).timeout(timeout);
      return _handleResponse<Message>(response, (json) {
        if (json is Map<String, dynamic>) {
          final apiResp = ApiResponse<Message>.fromJson(
            json,
            (data) => Message.fromJson(data as Map<String, dynamic>),
          );
          if (apiResp.success && apiResp.data != null) {
            return apiResp.data!;
          }
          throw ApiException(apiResp.error ?? 'Failed to update message');
        }
        throw ApiException('Unexpected JSON format for updateMessage');
      });
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    final uri = Uri.parse('$baseUrl/api/messages/$id');
    try {
      final response = await _client.delete(uri, headers: _getHeaders()).timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    final uri = Uri.parse('$baseUrl/api/status/$statusCode');
    try {
      final response = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      return _handleResponse<HTTPStatusResponse>(response, (json) {
        if (json is Map<String, dynamic>) {
          final apiResp = ApiResponse<HTTPStatusResponse>.fromJson(
            json,
            (data) => HTTPStatusResponse.fromJson(data as Map<String, dynamic>),
          );
          if (apiResp.success && apiResp.data != null) {
            return apiResp.data!;
          }
          throw ApiException(apiResp.error ?? 'Failed to get HTTP status');
        }
        throw ApiException('Unexpected JSON format for getHTTPStatus');
      });
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    final uri = Uri.parse('$baseUrl/api/health');
    try {
      final response = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ApiException('Failed health check');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
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
