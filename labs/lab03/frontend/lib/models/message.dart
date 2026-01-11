// If you want to use freezed, you can use the following command:
// dart pub add freezed_annotation
// dart pub add json_annotation
// dart pub add build_runner
// dart run build_runner build

class Message {
  // Add final int id field
  final int id;
  // Add final String username field
  final String username;
  // Add final String content field
  final String content;
  // Add final DateTime timestamp field
  final DateTime timestamp;

  // Add constructor with required parameters:
  // Message({required this.id, required this.username, required this.content, required this.timestamp});
  const Message({required this.id, required this.username, required this.content, required this.timestamp});

  // Add factory constructor fromJson(Map<String, dynamic> json)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
    // Parse id from json['id']
    id : json['id'] as int,
    // Parse username from json['username']
    username: json['username'] as String,
    // Parse content from json['content']
    content: json['content'] as String,
    // Parse timestamp from json['timestamp'] using DateTime.parse()
    timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Add toJson() method that returns Map<String, dynamic>
  Map<String, dynamic> toJson() {
  // Return map with 'id', 'username', 'content', and 'timestamp' keys
  // Convert timestamp to ISO string using toIso8601String()
    return {
      'id' : id,
      'username' : username,
      'content' : content,
      'timestamp' : timestamp.toIso8601String(),
    };
  }
}

class CreateMessageRequest {
  // Add final String username field
  final String username;
  // Add final String content field
  final String content;

  // Add constructor with required parameters:
  // CreateMessageRequest({required this.username, required this.content});
  const CreateMessageRequest({required this.username, required this.content});

  // Add toJson() method that returns Map<String, dynamic>
  Map<String, dynamic> toJson() {
    // Return map with 'username' and 'content' keys
    return {
      'username' : username,
      'content' : content,
    };
  }

  // Add validate() method that returns String? (error message or null)
  String? validate() {
    // Check if username is not empty, return "Username is required" if empty
    if (username.isEmpty) {
      return "Username is required";
    }
    // Check if content is not empty, return "Content is required" if empty
    if (content.isEmpty) {
      return "Content is required";
    }
    // Return null if validation passes
    return null;
  }
}

class UpdateMessageRequest {
  // Add final String content field
  final String content;
  // Add constructor with required parameters:
  // UpdateMessageRequest({required this.content});
  const UpdateMessageRequest({required this.content});

  // Add toJson() method that returns Map<String, dynamic>
  Map<String, dynamic> toJson() {
    // Return map with 'content' key
    return {
      'content' : content,
    };
  }

  // Add validate() method that returns String? (error message or null)
  String? validate() {
    // Check if content is not empty, return "Content is required" if empty
    if (content.isEmpty) {
      return "Content is required";
    }
    // Return null if validation passes
    return null;
  }
}

class HTTPStatusResponse {
  // Add final int statusCode field
  final int statusCode;
  // Add final String imageUrl field
  final String imageUrl;
  // Add final String description field
  final String description;

  // Add constructor with required parameters:
  // HTTPStatusResponse({required this.statusCode, required this.imageUrl, required this.description});
  const HTTPStatusResponse({required this.statusCode, required this.imageUrl, required this.description});

  // Add factory constructor fromJson(Map<String, dynamic> json)
  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) {
    return HTTPStatusResponse(
      // Parse statusCode from json['status_code']
      statusCode: json['status_code'] as int,
      // Parse imageUrl from json['image_url']
      imageUrl: json['image_url'] as String,
        // Parse description from json['description']
      description: json['description'] as String,
    );
  }
}

class ApiResponse<T> {
  // Add final bool success field
  final bool success;
  // Add final T? data field
  final T? data;
  // Add final String? error field
  final String? error;
  // Add constructor with optional parameters:
  // ApiResponse({required this.success, this.data, this.error});
  ApiResponse({required this.success, this.data, this.error});

  // Add factory constructor fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT)
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse(
      // Parse success from json['success']
      success: json['success'] as bool,
      // Parse data from json['data'] using fromJsonT if provided and data is not null
      data: json['data'] != null ? fromJsonT == null ? null : fromJsonT(json['data']) : null,
      // Parse error from json['error']
      error : json['error'] as String,
    );
  }
}
