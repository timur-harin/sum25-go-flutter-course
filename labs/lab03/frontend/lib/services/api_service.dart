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

  void dispose() => _client.close();

  Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  T _handleResponse<T>(
      http.Response resp, T Function(Map<String, dynamic>) fromJson) {
    final code = resp.statusCode;
    final body = resp.body;
    if (code >= 200 && code < 300) {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } else if (code >= 400 && code < 500) {
      throw NetworkException('Client error: ${resp.reasonPhrase}');
    } else if (code >= 500 && code < 600) {
      throw ServerException('Server error: ${resp.reasonPhrase}');
    } else {
      throw ApiException('Unexpected HTTP code: $code');
    }
  }

  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    throw UnimplementedError('TODO: Implement getMessages');
  }

  Future<Message> createMessage(CreateMessageRequest req) async {
    // TODO: Implement createMessage
    throw UnimplementedError('TODO: Implement createMessage');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest req) async {
    // TODO: Implement updateMessage
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  Future<HTTPStatusResponse> getHTTPStatus(int code) async {
    // TODO: Implement getHTTPStatus
    throw UnimplementedError('TODO: Implement getHTTPStatus');
  }

  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    throw UnimplementedError('TODO: Implement healthCheck');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String m) : super(m);
}

class ServerException extends ApiException {
  ServerException(String m) : super(m);
}

class ValidationException extends ApiException {
  ValidationException(String m) : super(m);
}
