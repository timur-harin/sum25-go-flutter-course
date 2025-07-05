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
    try {
      final timestamp = json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(); // fallback

      return Message(
        id: int.parse(json['id'].toString()),
        username: json['username'].toString(),
        content: json['content'].toString(),
        timestamp: timestamp,
      );
    } catch (e, stack) {
      print('Error parsing Message: $e');
      print('Stack trace: $stack');
      print('JSON data: $json');
      throw FormatException('Failed to parse Message: ${e.toString()}');
    }
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
    if (username.isEmpty) return "Username is required";
    if (content.isEmpty) return "Content is required";
    return null;
  }
}

class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  String? validate() {
    if (content.isEmpty) return "Content is required";
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
      statusCode: int.tryParse(json['status_code'].toString()) ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
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
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson(T Function(T)? toJsonT) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data!) : data,
      'error': error,
    };
  }
}
