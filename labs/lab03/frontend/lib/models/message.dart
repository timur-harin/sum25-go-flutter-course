// lib/models/message.dart
// Простые data-классы без зависимостей на freezed/json_serializable

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

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String? ?? '',
        content: json['content'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

/* ------------ запросы на создание / обновление ------------ */

class CreateMessageRequest {
  final String username;
  final String content;

  CreateMessageRequest({required this.username, required this.content});

  Map<String, dynamic> toJson() =>
      {'username': username, 'content': content};

  /// Возвращает текст ошибки или null, если всё ок
  String? validate() {
    if (username.trim().isEmpty) return 'Username is required';
    if (content.trim().isEmpty) return 'Content is required';
    return null;
  }
}

class UpdateMessageRequest {
  final String content;

  UpdateMessageRequest({required this.content});

  Map<String, dynamic> toJson() => {'content': content};

  String? validate() =>
      content.trim().isEmpty ? 'Content is required' : null;
}

/* ---------------- ответы вспомогательных энд-пойнтов ---------------- */

class HTTPStatusResponse {
  final int statusCode;
  final String imageUrl;
  final String description;

  HTTPStatusResponse({
    required this.statusCode,
    required this.imageUrl,
    required this.description,
  });

  factory HTTPStatusResponse.fromJson(Map<String, dynamic> json) =>
      HTTPStatusResponse(
        statusCode: (json['status_code'] as num).toInt(),
        imageUrl: json['image_url'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

/* ------------------- универсальный обёртка-ответ -------------------- */

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    final rawData = json['data'];
    final parsedData = (rawData != null && fromJsonT != null)
        ? fromJsonT(rawData as Map<String, dynamic>)
        : null;
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: parsedData,
      error: json['error'] as String?,
    );
  }
}
