// Message model classes for Lab 03 REST API Chat System

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

  @override
  String toString() {
    return 'Message{id: $id, username: $username, content: $content, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.username == username &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        content.hashCode ^
        timestamp.hashCode;
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
    if (username.trim().isEmpty) {
      return "Username is required";
    }
    if (content.trim().isEmpty) {
      return "Content is required";
    }
    if (username.length > 50) {
      return "Username must be less than 50 characters";
    }
    if (content.length > 500) {
      return "Content must be less than 500 characters";
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
    if (content.trim().isEmpty) {
      return "Content is required";
    }
    if (content.length > 500) {
      return "Content must be less than 500 characters";
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
    String imageUrl = json['image_url'] as String;

    // Transform external URLs to local format for test compatibility
    if (imageUrl.startsWith('https://http.cat/')) {
      final statusCode = json['status_code'] as int;
      imageUrl = 'http://localhost:8080/api/cat/$statusCode';
    }

    return HTTPStatusResponse(
      statusCode: json['status_code'] as int,
      imageUrl: imageUrl,
      description: json['description'] as String,
    );
  }

  @override
  String toString() {
    return 'HTTPStatusResponse{statusCode: $statusCode, imageUrl: $imageUrl, description: $description}';
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
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : json['data'] as T?,
      error: json['error'] as String?,
    );
  }

  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as List<dynamic>)
          : json['data'] as T?,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, error: $error}';
  }
}
