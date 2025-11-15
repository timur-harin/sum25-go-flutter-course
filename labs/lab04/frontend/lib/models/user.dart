import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  // Changed because of error, probably in time
  @JsonKey(name: 'created_at', fromJson: _fromJson, toJson: _toJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _fromJson, toJson: _toJson)
  final DateTime updatedAt;
  // Helper functions for fix errors with time  
  static DateTime _fromJson(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw Exception('Invalid date format');
  }

  static dynamic _toJson(DateTime date) {
    return date.toIso8601String(); // or millisecondsSinceEpoch if you prefer
  }

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Implement copyWith method
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Create a copy of User with updated fields
    // Return new User instance with updated values or original values if null
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt
      );
  }

  // Implement equality operator
  @override
  bool operator ==(Object other) {
    // Compare User objects for equality
    // Check if other is User and all fields are equal
    if (other is User) {
      return (name == other.name) && (email == other.email) && (createdAt == other.createdAt) && (updatedAt == other.updatedAt);
    }
    return false;
  }

  // Implement hashCode
  @override
  int get hashCode {
    // Generate hash code based on all fields
    return name.hashCode + email.hashCode + createdAt.hashCode + updatedAt.hashCode;
  }

  // Implement toString
  @override
  String toString() {
    // Return string representation of User
    return "User: {name: $name, email: $email}";
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

  // Implement validate method
  bool validate() {
    // Validate user creation request
    // - Name should not be empty and should be at least 2 characters
    if (name.length < 2) {
      return false;
    }
    // - Email should be valid format
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      return false;
    }
    
    return true;
  }
}
