import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class ChatMsg {
  final int msgId;
  final String user;
  final String body;
  final DateTime sentAt;

  ChatMsg({
    required this.msgId,
    required this.user,
    required this.body,
    required this.sentAt,
  });

  factory ChatMsg.fromJson(Map<String, dynamic> json) => ChatMsg(
        msgId: json['id'] as int,
        user: json['username'] as String,
        body: json['content'] as String,
        sentAt: DateTime.parse(json['timestamp'] as String),
      );
  Map<String, dynamic> toJson() => {
        'id': msgId,
        'username': user,
        'content': body,
        'timestamp': sentAt.toIso8601String(),
      };
}

@JsonSerializable()
class NewMsgReq {
  final String user;
  final String body;

  NewMsgReq({required this.user, required this.body});

  Map<String, dynamic> toJson() => {
        'username': user,
        'content': body,
      };

  String? check() {
    if (user.trim().isEmpty) return 'Имя обязательно';
    if (body.trim().isEmpty) return 'Текст обязателен';
    return null;
  }
}

@JsonSerializable()
class EditMsgReq {
  final String body;

  EditMsgReq({required this.body});

  Map<String, dynamic> toJson() => {
        'content': body,
      };

  String? check() {
    if (body.trim().isEmpty) return 'Текст обязателен';
    return null;
  }
}

@JsonSerializable()
class StatusInfo {
  @JsonKey(name: 'status_code')
  final int code;
  @JsonKey(name: 'image_url')
  final String img;
  final String desc;

  StatusInfo({required this.code, required this.img, required this.desc});

  factory StatusInfo.fromJson(Map<String, dynamic> json) => StatusInfo(
        code: json['status_code'] as int,
        img: json['image_url'] as String,
        desc: json['description'] as String,
      );
}

@JsonSerializable(genericArgumentFactories: true)
class ApiWrap<T> {
  final bool ok;
  final T? payload;
  final String? err;

  ApiWrap({required this.ok, this.payload, this.err});

  factory ApiWrap.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiWrap<T>(
      ok: json['success'] as bool,
      payload: json['data'] != null ? fromJsonT(json['data']) : null,
      err: json['error'] as String?,
    );
  }
}
