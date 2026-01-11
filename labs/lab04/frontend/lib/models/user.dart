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

  // Creates a copy of User with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Return new User instance with updated values or original values if null
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Compares User objects for equality
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

  // Generates hash code based on all fields
  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  // Returns string representation of User
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt, updatedAt: $updatedAt)';
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

  // Validates user creation request
  // - Name should not be empty and should be at least 2 characters
  // - Email should be valid format
  bool validate() {
    if (name.trim().length < 2) {
      return false;
    }
    // Simple email regex pattern
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email.trim())) {
      return false;
    }
    return true;
  }
}
