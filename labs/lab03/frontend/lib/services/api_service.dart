import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);

  late final http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() => _client.close();

  Map<String, String> _getHeaders() => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };


  Future<List<Message>> getMessages() async {
    throw UnimplementedError('TODO: Implement getMessages');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final err = request.validate();
    if (err != null) throw ValidationException(err);
    throw UnimplementedError('TODO: Implement createMessage');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final err = request.validate();
    if (err != null) throw ValidationException(err);
    throw UnimplementedError('TODO: Implement updateMessage');
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('TODO: Implement deleteMessage');
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode < 100 || statusCode > 599) {
      throw ValidationException('Invalid status code');
    }
    throw UnimplementedError('TODO: Implement getHTTPStatus');
  }

  Future<Map<String, dynamic>> healthCheck() async {
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
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
