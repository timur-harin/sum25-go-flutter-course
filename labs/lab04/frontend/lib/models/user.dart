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

  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    User user = User(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
    return user;
  }

  @override
  bool operator ==(Object other) {
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User\n id: $id, name: $name, email: $email, created at: $createdAt, updated at: $updatedAt';
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

  bool validate() {
    final regExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (name.length < 2 || !regExp.hasMatch(email)) {
      return false;
    } else {
      return true;
    }
  }
}
