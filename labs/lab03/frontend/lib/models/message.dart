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

  factory Message.fromJSON(Map<String, dynamic> json) {
    int id = json["id"] as int;
    String username = json["username"] as String;
    String content = json["content"] as String;
    DateTime timestamp = DateTime.parse(json["timestamp"] as String);

    return Message(
      id: id,
      username: username,
      content: content,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = <String, dynamic>{};

    // Fill the return map
    ret["id"] = id;
    ret["username"] = username;
    ret["content"] = content;
    ret["timestamp"] = timestamp;

    // Converted
    return ret;
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
    Map<String, dynamic> ret = <String, dynamic>{};

    // Fill the map
    ret["username"] = username;
    ret["content"] = content;

    return ret;
  }

  String? validate() {
    // Check the username
    if (username.isEmpty) {
      return "Username is required";
    }

    // Check the content
    if (content.isEmpty) {
      return "Content is required";
    }

    return null; // OK, no error
  }
}

class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret["content"] = content;
    return ret;
  }

  String? validate() {
    // Check the content
    if (content.isEmpty) {
      return "Content is required";
    }

    return null; // OK, no error
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
    int statusCode = json["status_code"] as int;
    String imageUrl = json["image_url"] as String;
    String description = json["description"] as String;

    return HTTPStatusResponse(
      statusCode: statusCode,
      imageUrl: imageUrl,
      description: description,
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
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    bool success = json["success"] as bool;
    T? data;
    if (fromJsonT != null) {
      data = fromJsonT(json);
    }
    String? error = json["error"] as String?;

    return ApiResponse(
      success: success,
      data: data,
      error: error,
    );
  }
}
