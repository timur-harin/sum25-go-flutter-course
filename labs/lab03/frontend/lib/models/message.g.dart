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
      'status_Code': instance.statusCode,
      'image_Url': instance.imageUrl,
      'description': instance.description,
    };
