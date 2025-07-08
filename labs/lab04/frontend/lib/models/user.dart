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
    // TODO: Create a copy of User with updated fields
    // Return new User instance with updated values or original values if null
    throw UnimplementedError('TODO: implement copyWith method');
  }

  // TODO: Implement equality operator
  @override
  bool operator ==(Object other) {
    // TODO: Compare User objects for equality
    // Check if other is User and all fields are equal
    return super == other;
  }

  // TODO: Implement hashCode
  @override
  int get hashCode {
    // TODO: Generate hash code based on all fields
    return super.hashCode;
  }

  // TODO: Implement toString
  @override
  String toString() {
    // TODO: Return string representation of User
    return super.toString();
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
    // TODO: Validate user creation request
    // - Name should not be empty and should be at least 2 characters
    // - Email should be valid format
    return false;
  }
}
