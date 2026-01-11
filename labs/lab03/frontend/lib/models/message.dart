import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  final String username;
  final String content;

  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class CreateMessageRequest {
  final String username;
  final String content;

  const CreateMessageRequest({required this.username, required this.content});

  Map<String, dynamic> toJson() => _$CreateMessageRequestToJson(this);

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

@JsonSerializable()
class UpdateMessageRequest {
  final String content;

  const UpdateMessageRequest({required this.content});

  Map<String, dynamic> toJson() => _$UpdateMessageRequestToJson(this);

  String? validate() {
    if (content == "") {
      return "Content is required";
    }
    return null;
  }
}

@JsonSerializable()
class HTTPStatusResponse {
  @JsonKey(name: 'status_code')
  final int statusCode;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String description;

  const HTTPStatusResponse(
      {required this.statusCode,
      required this.imageUrl,
      required this.description});

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$HTTPStatusResponseFromJson(json);
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse(
        success: json['success'] as bool,
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'] as Map<String, dynamic>)
            : null,
        error: json['error'] as String?);
  }
}
