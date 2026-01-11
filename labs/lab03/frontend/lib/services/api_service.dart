import 'dart:async';
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

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode < 500) {
      final error = json.decode(response.body)['error'] as String?;
      throw ClientException(error ?? 'Client error: $statusCode');
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected error: $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          final data = apiResponse.data as List<dynamic>;
          return data.map((msg) => Message.fromJson(msg)).toList();
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get messages');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError.toString());
    }

    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      )
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return Message.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to create message');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError.toString());
    }

    try {
      final response = await _client
          .put(
        Uri.parse('$baseUrl/api/messages/$id'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      )
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return Message.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to update message');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return HTTPStatusResponse.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
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

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}import 'dart:async';
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

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(decoded);
    } else if (statusCode >= 400 && statusCode < 500) {
      final error = json.decode(response.body)['error'] as String?;
      throw ClientException(error ?? 'Client error: $statusCode');
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ServerException('Server error: $statusCode');
    } else {
      throw ApiException('Unexpected error: $statusCode');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          final data = apiResponse.data as List<dynamic>;
          return data.map((msg) => Message.fromJson(msg)).toList();
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get messages');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError.toString());
    }

    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      )
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return Message.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to create message');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError.toString());
    }

    try {
      final response = await _client
          .put(
        Uri.parse('$baseUrl/api/messages/$id'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      )
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return Message.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to update message');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response, (json) {
        final apiResponse = APIResponse.fromJson(json);
        if (apiResponse.success) {
          return HTTPStatusResponse.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
        }
      });
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Health check failed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
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

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}