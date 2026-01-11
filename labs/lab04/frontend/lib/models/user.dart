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

  // TODO: Implement copyWith method
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

  // TODO: Implement equality operator
  @override
  bool operator ==(Object other) {
      if (identical(this, other)) return true;
      return other is User &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;
    }

  // TODO: Implement hashCode
  @override
  int get hashCode =>
        id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;

    @override
    String toString() {
      return 'User(id: $id, name: $name, email: $email, '
          'createdAt: $createdAt, updatedAt: $updatedAt)';
    }

    factory User.fromMap(Map<String, dynamic> map) {
      return User(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'name': name,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
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

  // TODO: Implement validate method
  bool validate() {
      final nameValid = name.trim().length >= 2;
      final emailRegex = RegExp(
          r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$'); // Простой email regex
      final emailValid = emailRegex.hasMatch(email.trim());

      return nameValid && emailValid;
    }
}
