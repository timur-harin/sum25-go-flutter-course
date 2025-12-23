// If you want to use freezed, you can use the following command:
// dart pub add freezed_annotation
// dart pub add json_annotation
// dart pub add build_runner
// dart run build_runner build

class Message {
  final int id;
  final String username;
  final String content;
  final DateTime timestamp;

  Message(
      {required this.id,
      required this.username,
      required this.content,
      required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      username: json['username'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Parse id from json['id']
  // Parse username from json['username']
  // Parse content from json['content']
  // Parse timestamp from json['timestamp'] using DateTime.parse()

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String()
    };
  }
}

class CreateMessageRequest {
  final String username;
  final String content;

  CreateMessageRequest({required this.username, required this.content});

  Map<String, dynamic> toJson() {
    return {'username': username, 'content': content};
  }

// Return map with 'username' and 'content' keys

  String? validate() {
    if (username == "") {
      return "Username is required";
    }
    if (content == "") {
      return "Content is required";
    }
    return null;
  }
}

class UpdateMessageRequest {
  final String content;

  // TODO: Add constructor with required parameters:
  UpdateMessageRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  String? validate() {
    if (content == "") {
      return "Content is required";
    }
    return null;
  }

// TODO: Add validate() method that returns String? (error message or null)
// Check if content is not empty, return "Content is required" if empty
// Return null if validation passes
}

class HTTPStatusResponse {
  final int statusCode;
  final String imageUrl;
  final String description;

  // TODO: Add constructor with required parameters:
  HTTPStatusResponse(
      {required this.statusCode,
      required this.imageUrl,
      required this.description});

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
      statusCode: json['status_code'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  // TODO: Add constructor with optional parameters:
  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
        success: json['success'], data: json['data'], error: json['error']);
  }
// Parse success from json['success']
// Parse data from json['data'] using fromJsonT if provided and data is not null
// Parse error from json['error']
}
