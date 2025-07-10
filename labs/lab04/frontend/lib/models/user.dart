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
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    throw UnimplementedError('TODO: implement copyWith method');
  }

  // TODO: Implement equality operator
  @override
  bool operator ==(Object other) {
    // TODO: Compare User objects for equality
    // Check if other is User and all fields are equal
    if(identical(this, other)) return true;
    if(other.runtimeType != runtimeType) return false;

    return other is User
      && other.id == id
      && other.name == name
      && other.email == email
      && other.createdAt == createdAt
      && other.updatedAt == updatedAt;
  }

  // TODO: Implement hashCode
  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    createdAt,
    updatedAt
  );
  // TODO: Implement toString
  @override
  String toString() {
    // TODO: Return string representation of User

    return "$id $name $email $createdAt $updatedAt";
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
    if(name.isEmpty || name.length < 2){
      throw Exception("Invalid name");
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if(!emailRegex.hasMatch(email)){
      throw Exception('Invalid email');
    }

    return true;
  }
}
