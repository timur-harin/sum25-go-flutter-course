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

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final statusCode = response.statusCode;
    if (response.body.trim().isEmpty) {
      throw ApiException('Empty response body');
  }
    final data = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return fromJson(data);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(data['error'] ?? 'Client error');
    } else if (statusCode >= 500) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected error: $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final uri = Uri.parse('$baseUrl/api/messages');
      final res = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      final data = jsonDecode(res.body);
      final messages = (data['data'] as List)
          .map((e) => Message.fromJson(e))
          .toList();
      return messages;
    } catch (e) {
      throw NetworkException('Failed to fetch messages: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final error = request.validate();
    if (error != null) throw ValidationException(error);

    try {
      final uri = Uri.parse('$baseUrl/api/messages');
      final res = await _client
          .post(uri,
              headers: _getHeaders(),
              body: jsonEncode(request.toJson()))
          .timeout(timeout);
      final parsed = _handleResponse(res, (json) => ApiResponse.fromJson(json, Message.fromJson));
      return parsed.data!;
    } catch (e) {
      rethrow;
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // final error = request.validate();
    // if (error != null) throw ValidationException(error);

    // try {
    //   final uri = Uri.parse('$baseUrl/api/messages/$id');
    //   final res = await _client
    //       .put(uri,
    //           headers: _getHeaders(),
    //           body: jsonEncode(request.toJson()))
    //       .timeout(timeout);
    //   final parsed = _handleResponse(res, (json) => ApiResponse.fromJson(json, Message.fromJson));
    //   return parsed.data!;
    // } catch (e) {
    //   rethrow;
    // }
    throw UnimplementedError();
  }

  Future<void> deleteMessage(int id) async {
    // try {
    //   final uri = Uri.parse('$baseUrl/api/messages/$id');
    //   final res = await _client
    //       .delete(uri, headers: _getHeaders())
    //       .timeout(timeout);

    //   if (res.statusCode != 204) {
    //     throw ApiException('Failed to delete message');
    //   }
    // } catch (e) {
    //   throw NetworkException('Delete failed: $e');
    // }
    throw UnimplementedError();
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
  // try {
  //   final uri = Uri.parse('$baseUrl/api/status/$statusCode');
  //   final res = await _client.get(uri, headers: _getHeaders()).timeout(timeout);

  //   if (res.body.trim().isEmpty) {
  //     throw ApiException('Empty response body');
  //   }

  //   final parsed = _handleResponse(
  //     res,
  //     (json) => ApiResponse.fromJson(json, HTTPStatusResponse.fromJson),
  //   );
  //   return parsed.data!;
  // } catch (e) {
  //   if (e is FormatException) {
  //     throw ApiException('Invalid JSON response');
  //   }
  //   rethrow;
  // }
  throw UnimplementedError();
}


  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final res = await _client.get(uri, headers: _getHeaders()).timeout(timeout);
      return jsonDecode(res.body);
    } catch (e) {
      throw NetworkException('Health check failed: $e');
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
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
