import 'dart:convert';

class Message {
  final int id;
  final String username;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CreateMessageRequest {
  final String username;
  final String content;

  CreateMessageRequest({
    required this.username,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
    };
  }

  String? validate() {
    if (username.isEmpty) {
      return 'Username is required';
    }
    if (content.isEmpty) {
      return 'Content is required';
    }
    return null;
  }
}

class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  String? validate() {
    if (content.isEmpty) {
      return 'Content is required';
    }
    return null;
  }
}

class HTTPStatusResponse {
  final int statusCode;
  final String imageUrl;
  final String description;

  HTTPStatusResponse({
    required this.statusCode,
    required this.imageUrl,
    required this.description,
  });

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
      statusCode: json['status_code'] as int,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final success = json['success'] as bool;
    T? data;
    if (json.containsKey('data') && json['data'] != null && fromJsonT != null) {
      final rawData = json['data'];
      if (rawData is List) {
        // Если rawData — список, парсим каждый элемент и собираем в список
        data = fromJsonT(rawData) as T;
      } else {
        // Иначе парсим как одиночный объект
        data = fromJsonT(rawData);
      }
    }
    final error = json['error'] as String?;
    return ApiResponse<T>(
      success: success,
      data: data,
      error: error,
    );
  }
}
