import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
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

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] as bool) {
          final list = body['data'] as List<dynamic>;
          return list
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw ApiException(body['error'] ?? 'Unknown error');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ApiException(
            'Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final wrapped = jsonDecode(response.body) as Map<String, dynamic>;
        final resp = ApiResponse.fromJson(
            wrapped, (data) => Message.fromJson(data));
        return resp.data!;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ApiException(
            'Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validation = request.validate();
    if (validation != null) throw ValidationException(validation);
    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/\$id'),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final wrapped = jsonDecode(response.body) as Map<String, dynamic>;
        final resp = ApiResponse.fromJson(
            wrapped, (data) => Message.fromJson(data));
        return resp.data!;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ApiException(
            'Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/\$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ApiException(
            'Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/\$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final wrapped = jsonDecode(response.body) as Map<String, dynamic>;
        final resp = ApiResponse.fromJson(
            wrapped, (data) => HTTPStatusResponse.fromJson(data));
        return resp.data!;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ApiException(
            'Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }
}