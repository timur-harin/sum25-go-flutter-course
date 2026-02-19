import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Реализация метода copyWith
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Реализация оператора равенства
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    return id == other.id &&
        name == other.name &&
        email == other.email &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  // Реализация hashCode
  @override
  int get hashCode {
    return Object.hash(id, name, email, createdAt, updatedAt);
  }

  // Реализация toString
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;

  CreateUserRequest({
    required this.name,
    required this.email,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);

  // Реализация метода validate
  bool validate() {
    // Имя не должно быть пустым и должно содержать минимум 2 символа
    if (name.trim().length < 2) {
      return false;
    }
    // Проверка email на корректный формат
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }
    return true;
  }
}
