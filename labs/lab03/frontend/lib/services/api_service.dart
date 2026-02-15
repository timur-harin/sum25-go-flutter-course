import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return fromJson(jsonMap);
    } else if (status >= 400 && status < 500) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      throw ApiException(jsonMap['error'] ?? 'Client error');
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error: $status');
    } else {
      throw ApiException('Unexpected error: $status');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      final apiResp = _handleResponse<ApiResponse<List<Message>>>(
        response,
        (jsonMap) {
          final api = ApiResponse<List<Message>>.fromJson(
            jsonMap,
            (data) => (data as List).map((e) => Message.fromJson(e)).toList(),
          );
          if (!api.success) throw ApiException(api.error ?? 'Unknown error');
          return api;
        },
      );
      return apiResp.data ?? [];
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResp = _handleResponse<ApiResponse<Message>>(
        response,
        (jsonMap) {
          final api = ApiResponse<Message>.fromJson(jsonMap, (data) => Message.fromJson(data));
          if (!api.success) throw ApiException(api.error ?? 'Unknown error');
          return api;
        },
      );
      return apiResp.data!;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResp = _handleResponse<ApiResponse<Message>>(
        response,
        (jsonMap) {
          final api = ApiResponse<Message>.fromJson(jsonMap, (data) => Message.fromJson(data));
          if (!api.success) throw ApiException(api.error ?? 'Unknown error');
          return api;
        },
      );
      return apiResp.data!;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);
      final apiResp = _handleResponse<ApiResponse<HTTPStatusResponse>>(
        response,
        (jsonMap) {
          final api = ApiResponse<HTTPStatusResponse>.fromJson(jsonMap, (data) => HTTPStatusResponse.fromJson(data));
          if (!api.success) throw ApiException(api.error ?? 'Unknown error');
          return api;
        },
      );
      return apiResp.data!;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed');
      }
    } catch (e) {
      throw NetworkException(e.toString());
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
