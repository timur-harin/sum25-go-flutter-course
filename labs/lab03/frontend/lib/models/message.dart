import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
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

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class CreateMessageRequest {
  final String username;
  final String content;

  CreateMessageRequest({
    required this.username,
    required this.content,
  });

  factory CreateMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMessageRequestToJson(this);

  String? validate() {
    if (username.trim().isEmpty) return 'Username is required';
    if (content.trim().isEmpty) return 'Content is required';
    return null;
  }
}

@JsonSerializable()
class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({
    required this.content,
  });

  factory UpdateMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateMessageRequestToJson(this);

  String? validate() {
    if (content.trim().isEmpty) return 'Content is required';
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

  HTTPStatusResponse({
    required this.statusCode,
    required this.imageUrl,
    required this.description,
  });

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$HTTPStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HTTPStatusResponseToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
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
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
