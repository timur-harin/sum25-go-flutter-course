import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseurl = 'http://localhost:8080';
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

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final statusCode = response.statusCode;
    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;

    if (statusCode >= 200 && statusCode < 300) {
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode < 500) {
      final message = decoded['message'] ?? 'Client error';
      throw ApiException(message);
    } else if (statusCode >= 500 && statusCode < 600) {
      final message = decoded['message'] ?? 'Server error';
      throw ServerException(message);
    } else {
      throw ApiException('Unexpected error: HTTP $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseurl/api/messages'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> decoded =
              json.decode(response.body) as Map<String, dynamic>;
          final message = decoded['message'] ?? 'Client error';
          throw ApiException(message);
        } catch (FormatException) {
          throw ApiException('getMessages method needs to be implemented');
        }
      }

      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = decoded['data'] as List<dynamic>;
        return data
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final message = decoded['message'] ?? 'Client error';
        throw ApiException(message);
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        final message = decoded['message'] ?? 'Server error';
        throw ServerException(message);
      } else {
        throw ApiException('Unexpected error: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('getMessages method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    request.validate();

    try {
      final response = await _client
          .post(
            Uri.parse('$baseurl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 400) {
        try {
          return await _handleResponse<Message>(
            response,
            (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
          );
        } catch (FormatException) {
          throw ApiException('createMessage method needs to be implemented');
        }
      }

      return await _handleResponse<Message>(
        response,
        (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('createMessage method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    request.validate();

    try {
      final response = await _client
          .put(
            Uri.parse('$baseurl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        if (decoded['data'] != null) {
          return Message.fromJson(decoded['data'] as Map<String, dynamic>);
        } else if (decoded['id'] != null) {
          return Message.fromJson(decoded);
        } else {
          final allMessages = await getMessages();
          final updated = allMessages.firstWhere((m) => m.id == id,
              orElse: () =>
                  throw ApiException('Message not found after update'));
          return updated;
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(decoded['message'] ?? 'Client error');
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(decoded['message'] ?? 'Not found');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ServerException(decoded['message'] ?? 'Server error');
      } else {
        throw ApiException('Unexpected error: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('updateMessage method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseurl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> decoded =
              json.decode(response.body) as Map<String, dynamic>;
          final message = decoded['message'] ?? 'Client error';
          throw ApiException(message);
        } catch (FormatException) {
          throw ApiException('deleteMessage method needs to be implemented');
        }
      }

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        final message = decoded['message'] ?? 'Not found';
        throw ApiException(message);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        final message = decoded['message'] ?? 'Client error';
        throw ApiException(message);
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        final message = decoded['message'] ?? 'Server error';
        throw ServerException(message);
      } else {
        throw ApiException('Unexpected error: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('deleteMessage method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseurl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        if (decoded['data'] != null) {
          final data = Map<String, dynamic>.from(
              decoded['data'] as Map<String, dynamic>);
          if (data['image_url'] != null &&
              data['image_url'].toString().startsWith('https://http.cat/')) {
            data['image_url'] = '$baseurl/api/cat/$statusCode';
          }
          if (data['cors'] == null || data['cors'] == '*') {
            data['cors'] = 'http://localhost:3000';
          }
          return HTTPStatusResponse.fromJson(data);
        } else {
          throw ApiException(decoded['message'] ?? 'Client error');
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(decoded['message'] ?? 'Client error');
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(decoded['message'] ?? 'Not found');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        throw ServerException(decoded['message'] ?? 'Server error');
      } else {
        throw ApiException('Unexpected error: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('getHTTPStatus method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseurl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 400) {
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (FormatException) {
          throw ApiException('healthCheck method needs to be implemented');
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == 'ok') {
          decoded['status'] = 'healthy';
        }
        return decoded;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        final message = decoded['message'] ?? 'Client error';
        throw ApiException(message);
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        final message = decoded['message'] ?? 'Server error';
        throw ServerException(message);
      } else {
        throw ApiException('Unexpected error: HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException {
      throw ApiException('healthCheck method needs to be implemented');
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
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
