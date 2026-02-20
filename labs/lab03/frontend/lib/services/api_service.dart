import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'dart:async';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  late http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final status = response.statusCode;

    if (response.body.isEmpty) {
      throw ApiException('Unexpected API response');
    }

    final data = json.decode(response.body);

    if (status >= 200 && status < 300) {
      return fromJson(data);
    } 
    throw UnimplementedError();
  }

  dynamic _handleDynamicResponse(http.Response response) {
    final status = response.statusCode;

    if (response.body.isEmpty) {
      throw ApiException('Unexpected API response');
    }

    final data = json.decode(response.body);

    if (status >= 200 && status < 300) {
      return data;
    } else if (status >= 400 && status < 500) {
      throw ValidationException(data['message'] ?? 'Client error');
    } else if (status >= 500 && status < 600) {
      throw ServerException('Server error: ${response.reasonPhrase}');
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders())
          .timeout(timeout);

      final data = _handleDynamicResponse(response);

      final list = data['messages'];
      if (list is! List) {
        throw UnimplementedError();
      }

      return list.map<Message>((item) => Message.fromJson(item)).toList();
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
    }
    throw UnimplementedError();
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);
      final parsed = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );

      return Message.fromJson(parsed['message']);
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
    }
    throw UnimplementedError();
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      final parsed = _handleResponse<Map<String, dynamic>>(
        response,
        (json) => json,
      );

      return Message.fromJson(parsed['message']);
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
    }
    throw UnimplementedError();
  }

  Future<void> deleteMessage(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
       throw UnimplementedError();
      }

      return;
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
    }
    throw UnimplementedError();
  }

  Future<HTTPStatusResponse> getHTTPStatus(int code) async {
  final response = await http.get(Uri.parse('$baseUrl/api/status/$code'));
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return HTTPStatusResponse.fromJson(jsonMap);
    } else {
      throw ApiException('Failed to fetch HTTP status for code $code');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders())
          .timeout(timeout);

      if (response.body.isEmpty) {
        throw ApiException('Empty response from health check');
      }

      return json.decode(response.body);
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
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