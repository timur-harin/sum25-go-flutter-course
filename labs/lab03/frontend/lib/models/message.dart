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

  // TODO: Add constructor with required parameters:
  // Message({required this.id, required this.username, required this.content, required this.timestamp});

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json)
  // Parse id from json['id']
  // Parse username from json['username']
  // Parse content from json['content']
  // Parse timestamp from json['timestamp'] using DateTime.parse()

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'id', 'username', 'content', and 'timestamp' keys
  // Convert timestamp to ISO string using toIso8601String()
}

class CreateMessageRequest {
  // TODO: Add final String username field
  // TODO: Add final String content field

  // TODO: Add constructor with required parameters:
  // CreateMessageRequest({required this.username, required this.content});

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'username' and 'content' keys

  // TODO: Add validate() method that returns String? (error message or null)
  // Check if username is not empty, return "Username is required" if empty
  // Check if content is not empty, return "Content is required" if empty
  // Return null if validation passes
}

class UpdateMessageRequest {
  // TODO: Add final String content field

  // TODO: Add constructor with required parameters:
  // UpdateMessageRequest({required this.content});

  // TODO: Add toJson() method that returns Map<String, dynamic>
  // Return map with 'content' key

  // TODO: Add validate() method that returns String? (error message or null)
  // Check if content is not empty, return "Content is required" if empty
  // Return null if validation passes
}

class HTTPStatusResponse {
  // TODO: Add final int statusCode field
  // TODO: Add final String imageUrl field
  // TODO: Add final String description field

  // TODO: Add constructor with required parameters:
  // HTTPStatusResponse({required this.statusCode, required this.imageUrl, required this.description});

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json)
  // Parse statusCode from json['status_code']
  // Parse imageUrl from json['image_url']
  // Parse description from json['description']
}

class ApiResponse<T> {
  // TODO: Add final bool success field
  // TODO: Add final T? data field
  // TODO: Add final String? error field

  // TODO: Add constructor with optional parameters:
  // ApiResponse({required this.success, this.data, this.error});

  // TODO: Add factory constructor fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT)
  // Parse success from json['success']
  // Parse data from json['data'] using fromJsonT if provided and data is not null
  // Parse error from json['error']
}
