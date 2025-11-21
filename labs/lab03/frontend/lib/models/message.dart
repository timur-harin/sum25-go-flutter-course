// If you want to use freezed, you can use the following command:
// dart pub add freezed_annotation
// dart pub add json_annotation
// dart pub add build_runner
// dart run build_runner build

class Message {
  // TODO: Add final int id field
  // TODO: Add final String username field
  // TODO: Add final String content field
  // TODO: Add final DateTime timestamp field
  final int id;
  final String username;
  final String content;
  final DateTime timestamp;

  // TODO: Add constructor with required parameters:
  // Message({required this.id, required this.username, required this.content, required this.timestamp});
  const Message({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json)
  // Parse id from json['id']
  // Parse username from json['username']
  // Parse content from json['content']
  // Parse timestamp from json['timestamp'] using DateTime.parse()
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'id', 'username', 'content', and 'timestamp' keys
  // Convert timestamp to ISO string using toIso8601String()
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
  // TODO: Add final String username field
  // TODO: Add final String content field

  final String username;
  final String content;

  // TODO: Add constructor with required parameters:
  // CreateMessageRequest({required this.username, required this.content});

  const CreateMessageRequest({
    required this.username,
    required this.content,
  });

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'username' and 'content' keys
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
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
  // TODO: Add final String content field

  final String content;

  // TODO: Add constructor with required parameters:
  // UpdateMessageRequest({required this.content});

  const UpdateMessageRequest({
    required this.content,
  });

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'content' key
  Map<String, dynamic> toJson() {
    return {
      'content': content,
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
  // TODO: Add final int statusCode field
  // TODO: Add final String imageUrl field
  // TODO: Add final String description field

  final int statusCode;
  final String imageUrl;
  final String description;

  // TODO: Add constructor with required parameters:
  // HTTPStatusResponse({required this.statusCode, required this.imageUrl, required this.description});

  const HTTPStatusResponse({
    required this.statusCode,
    required this.imageUrl,
    required this.description,
  });

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json)
  // Parse statusCode from json['status_code']
  // Parse imageUrl from json['image_url']
  // Parse description from json['description']
  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
      statusCode: json['status_code'] as int,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
    );
  }
}

class ApiResponse<T> {
  // TODO: Add final bool success field
  // TODO: Add final T? data field
  // TODO: Add final String? error field

  final bool success;
  final T? data;
  final String? error;

  // TODO: Add constructor with optional parameters:
  // ApiResponse({required this.success, this.data, this.error});

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT)
  // Parse success from json['success']
  // Parse data from json['data'] using fromJsonT if provided and data is not null
  // Parse error from json['error']
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    T? data;
    if (json['data'] != null && fromJsonT != null) {
      data = fromJsonT(json['data'] as Map<String, dynamic>);
    } else if (json['data'] != null) {
      data = json['data'] as T;
    }

    return ApiResponse<T>(
      success: json['success'] as bool,
      data: data,
      error: json['error'] as String?,
    );
  }
}
