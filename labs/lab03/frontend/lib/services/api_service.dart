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
      final decoded = json.decode(response.body);
      return fromJson(decoded);
    } else if (status >= 400 && status < 500) {
      try {
        final decoded = json.decode(response.body);
        throw ApiException(decoded['error'] ?? 'Client error');
      } catch (_) {
        throw ApiException(response.body.isNotEmpty ? response.body : 'Client error');
      }
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
      final apiResp = _handleResponse(response, (json) => ApiResponse.fromJson(json));
      final data = apiResp.data as List<dynamic>;
      return data.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    request.validate();
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResp = _handleResponse(response, (json) => ApiResponse.fromJson(json));
      return Message.fromJson(apiResp.data as Map<String, dynamic>);
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    request.validate();
    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(), body: json.encode(request.toJson()))
          .timeout(timeout);
      final apiResp = _handleResponse(response, (json) => ApiResponse.fromJson(json));
      return Message.fromJson(apiResp.data as Map<String, dynamic>);
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
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
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ApiException('Invalid status code');
    }
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);
      final apiResp = _handleResponse(response, (json) => ApiResponse.fromJson(json));
      return HTTPStatusResponse.fromJson(apiResp.data as Map<String, dynamic>);
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      return json.decode(response.body) as Map<String, dynamic>;
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException(e.toString());
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
