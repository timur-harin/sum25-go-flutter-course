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

  // copyWith method implementation
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Let's create a copy of User with updated values of original values
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Equality operator implementation
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

  // Hashcode implementation
  @override
  int get hashCode {
    return Object.hash(
      id.hashCode,
      name.hashCode,
      email.hashCode,
      createdAt.hashCode,
      updatedAt.hashCode,
    );
  }

  // toString implementation
  @override
  String toString() {
    return  'User(id: $id, name: $name, email: $email, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
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

  // Validate method implementation
  bool validate() {
    // Checker for name correctness (not empty and more than two symbols)
    if (name.isEmpty || name.length < 2){
      return false;
    }

    // To simplify the email validation let's use regex
    // Regex contains all letters && numbers && special symbols
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    return emailRegex.hasMatch(email);
  }
}
