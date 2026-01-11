import 'package:flutter/material.dart';

@immutable
class Message {
  final int id;
  final String username;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.parse(json['id']),
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

@immutable
class CreateMessageRequest {
  final String username;
  final String content;

  const CreateMessageRequest({
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
      return "Username is required";
    }
    if (content.isEmpty) {
      return "Content is required";
    }
    return null;
  }
}

@immutable
class UpdateMessageRequest {
  final String content;

  const UpdateMessageRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  String? validate() {
    if (content.isEmpty) {
      return "Content is required";
    }
    return null;
  }
}

@immutable
class HTTPStatusResponse {
  final int statusCode;
  final String imageUrl;
  final String description;

  const HTTPStatusResponse({
    required this.statusCode,
    required this.imageUrl,
    required this.description,
  });

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
        statusCode: json['status_code'] as int,
        imageUrl: json['image_url'] as String,
        description: json['description'] as String);
  }
}

@immutable
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    final jsonData = json['data'];
    return ApiResponse(
        success: bool.parse(json['success'], caseSensitive: false),
        data: (jsonData != null && fromJsonT != null)
            ? fromJsonT(jsonData as Map<String, dynamic>)
            : null,
        error: json['error'] as String?);
  }
}
