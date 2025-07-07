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
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decoded);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final decoded = json.decode(response.body);
      final message = decoded is Map<String, dynamic> && decoded['error'] != null
          ? decoded['error']
          : 'Client error: ${response.statusCode}';
      throw ApiException(message.toString());
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      final apiResponse = _handleResponse<ApiResponse<List<Message>>>(
        response,
        (json) => ApiResponse<List<Message>>(
          success: json['success'] as bool,
          data: (json['data'] as List<dynamic>?)?.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList(),
          error: json['error'] as String?,
        ),
      );
      if (apiResponse.data == null) {
        return [];
      }
      return apiResponse.data!;
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) {
      throw ValidationException(validation);
    }
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResponse = _handleResponse<ApiResponse<Message>>(
        response,
        (json) => ApiResponse<Message>(
          success: json['success'] as bool,
          data: json['data'] != null ? Message.fromJson(json['data']) : null,
          error: json['error'] as String?,
        ),
      );
      if (apiResponse.data == null) {
        throw ApiException('No message returned');
      }
      return apiResponse.data!;
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) {
      throw ValidationException(validation);
    }
    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResponse = _handleResponse<ApiResponse<Message>>(
        response,
        (json) => ApiResponse<Message>(
          success: json['success'] as bool,
          data: json['data'] != null ? Message.fromJson(json['data']) : null,
          error: json['error'] as String?,
        ),
      );
      if (apiResponse.data == null) {
        throw ApiException('No message returned');
      }
      return apiResponse.data!;
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
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
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException('Invalid HTTP status code');
    }
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);
      final apiResponse = _handleResponse<ApiResponse<HTTPStatusResponse>>(
        response,
        (json) => ApiResponse<HTTPStatusResponse>(
          success: json['success'] as bool,
          data: json['data'] != null ? HTTPStatusResponse.fromJson(json['data']) : null,
          error: json['error'] as String?,
        ),
      );
      if (apiResponse.data == null) {
        throw ApiException('No status returned');
      }
      return apiResponse.data!;
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
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
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      rethrow;
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
