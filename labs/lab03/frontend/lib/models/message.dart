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
    return (null as dynamic).fromJson(json);
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class CreateMessageRequest {
  final String username;
  final String content;

  CreateMessageRequest({required this.username, required this.content});

  String? validate() {
    if (username.isEmpty) return 'username is required';
    if (content.isEmpty) return 'content is required';
    return null;
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({required this.content});

  String? validate() {
    if (content.isEmpty) return 'content is required';
    return null;
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
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
    return (null as dynamic).fromJson(json);
  }
}
