import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  Map<String, String> _getHeaders() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  T _handleResponse<T>(
      http.Response response, T Function(dynamic) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final apiResp = ApiResponse<T>.fromJson(decoded, fromJson);
      if (apiResp.success) {
        return apiResp.data!;
      }
      throw ApiException(apiResp.error ?? 'Unknown error');
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiException('Client error: ${response.body}');
    }
    if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    }
    throw ApiException('Unexpected status code: ${response.statusCode}');
  }

  Future<List<Message>> getMessages() async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<List<Message>>(resp, (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final err = request.validate();
    if (err != null) throw ValidationException(err);

    try {
      final resp = await _client
          .post(Uri.parse('$baseUrl/api/messages'),
              headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);
      return _handleResponse<Message>(
          resp, (data) => Message.fromJson(data as Map<String, dynamic>));
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final err = request.validate();
    if (err != null) throw ValidationException(err);

    try {
      final resp = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'),
              headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);
      return _handleResponse<Message>(
          resp, (data) => Message.fromJson(data as Map<String, dynamic>));
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final resp = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);
      if (resp.statusCode != 204) {
        throw ApiException('Failed to delete message');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'),
              headers: _getHeaders())
          .timeout(timeout);
      return _handleResponse<HTTPStatusResponse>(
          resp, (data) => HTTPStatusResponse.fromJson(data as Map<String, dynamic>));
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('success')) {
          final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
              decoded, (data) => data as Map<String, dynamic>);
          if (apiResp.success) {
            return apiResp.data ?? <String, dynamic>{};
          }
          throw ApiException(apiResp.error ?? 'Health check failed');
        }
        return decoded as Map<String, dynamic>;
      }
      throw ApiException('Health check failed');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
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
