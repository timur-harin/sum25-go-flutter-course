// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

CreateMessageRequest _$CreateMessageRequestFromJson(
        Map<String, dynamic> json) =>
    CreateMessageRequest(
      username: json['username'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$CreateMessageRequestToJson(
        CreateMessageRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'content': instance.content,
    };

UpdateMessageRequest _$UpdateMessageRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateMessageRequest(
      content: json['content'] as String,
    );

Map<String, dynamic> _$UpdateMessageRequestToJson(
        UpdateMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

HTTPStatusResponse _$HTTPStatusResponseFromJson(Map<String, dynamic> json) =>
    HTTPStatusResponse(
      statusCode: (json['status_code'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$HTTPStatusResponseToJson(HTTPStatusResponse instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'image_url': instance.imageUrl,
      'description': instance.description,
    };

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'error': instance.error,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
