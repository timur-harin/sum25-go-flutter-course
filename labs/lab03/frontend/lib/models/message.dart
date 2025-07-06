// If you want to use freezed, you can use the following command:
// dart pub add freezed_annotation
// dart pub add json_annotation
// dart pub add build_runner
// dart run build_runner build

import 'package:flutter/material.dart';

class HealthCheck {
  final String message;
  final String status;
  final DateTime timestamp;
  final int totalMessages;

  HealthCheck({
    required this.message,
    required this.status,
    required this.timestamp,
    required this.totalMessages
  });

  factory HealthCheck.fromJson(Map<String, dynamic> json) {
    return HealthCheck(
      message: json['message'], 
      status: json['status'], 
      timestamp: DateTime.parse(json['timestamp']), 
      totalMessages: json['total_messages'] as int
    );
  }
}

class Message {
  final int id;
  final String username;
  final String content;
  final DateTime timestamp;

  // TODO: Add constructor with required parameters:
  Message({
    required this.id, 
    required this.username, 
    required this.content, 
    required this.timestamp
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],                               // Parse id from json['id']
      username: json['username'],                   // Parse username from json['username']
      content: json['content'],                     // Parse content from json['content']
      timestamp: DateTime.parse(json['timestamp'])  // Parse timestamp from json['timestamp'] using DateTime.parse()
    );
  }

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'id', 'username', 'content', and 'timestamp' keys
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String()  // Convert timestamp to ISO string using toIso8601String()
    };
  }
}

class CreateMessageRequest {
  final String username;
  final String content;

  // TODO: Add constructor with required parameters:
  CreateMessageRequest({
    required this.username, 
    required this.content
  });

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'username' and 'content' keys
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content
    };
  }

  // TODO: Add validate() method that returns String? (error message or null)
  // Check if username is not empty, return "Username is required" if empty
  // Check if content is not empty, return "Content is required" if empty
  // Return null if validation passes
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

class UpdateMessageRequest {
  final String content;

  // TODO: Add constructor with required parameters:
  UpdateMessageRequest({required this.content});

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'content' key
  Map<String, dynamic> toJson() {
    return {
      'content': content
    };
  }

  // TODO: Add validate() method that returns String? (error message or null)
  // Check if content is not empty, return "Content is required" if empty
  // Return null if validation passes
  String? validate() {
    if (content.isEmpty) {
      return "Content is required";
    }
    return null;
  }
}

class HTTPStatusResponse {
  final int statusCode;
  final String imageUrl;
  final String description;

  // TODO: Add constructor with required parameters:
  HTTPStatusResponse({required this.statusCode, required this.imageUrl, required this.description});

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json)
  // Parse statusCode from json['status_code']
  // Parse imageUrl from json['image_url']
  // Parse description from json['description']
  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
      statusCode: json['status_code'], 
      imageUrl: json['image_url'], 
      description: json['description']
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  // TODO: Add constructor with optional parameters:
  ApiResponse({required this.success, this.data, this.error});

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT)
  // Parse success from json['success']
  // Parse data from json['data'] using fromJsonT if provided and data is not null
  // Parse error from json['error']
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse(
      success: json['success'],
      data: fromJsonT == null ? null : fromJsonT(json['data']),
      error: json['error']
    );
  }
}
