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
    return User(
      id: id != null ? id : this.id,
      name: name != null ? name : this.name,
      email: email != null ? email : this.email,
      createdAt: createdAt != null ? createdAt : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt : this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.email == email &&
        other.name == name &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    int hash = 17;
    hash = 31 * hash + id.hashCode;
    hash = 31 * hash + name.hashCode;
    hash = 31 * hash + email.hashCode;
    hash = 31 * hash + createdAt.hashCode;
    hash = 31 * hash + updatedAt.hashCode;
    return hash;
  }

  @override
  String toString() {
    return '''
User(
  id: $id,
  name: $name,
  email: $email,
  createdAt: $createdAt,
  updatedAt: $updatedAt
)''';
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
    final emailPattern = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    if (!emailPattern.hasMatch(email)) {
      return false;
    }
    if (name.length < 2) {
      return false;
    }
    return true;
  }
}