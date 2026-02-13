import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents a user entity with typical user fields.
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

  /// Factory constructor to create a User instance from JSON map.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts the User instance to JSON map.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Returns a copy of the current User with optional field overrides.
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

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Request data structure to create a new user.
/// Validates basic constraints on fields.
@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;

  CreateUserRequest({
    required this.name,
    required this.email,
  });

  /// Factory constructor to create CreateUserRequest instance from JSON.
  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);

  /// Converts CreateUserRequest instance to JSON map.
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);

  /// Validates the CreateUserRequest fields:
  /// - name must be at least 2 characters after trimming
  /// - email must match a basic email regex pattern
  bool validate() {
    final RegExp emailPattern = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    final String trimmedName = name.trim();
    return trimmedName.length >= 2 && emailPattern.hasMatch(email);
  }
}
