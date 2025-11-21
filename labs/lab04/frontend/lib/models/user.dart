import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model represents a user in the Flutter application
/// This model demonstrates JSON serialization, immutable data patterns,
/// and validation for user data management.
/// 
/// Features:
/// - JSON serialization with custom field mapping
/// - Immutable data structure with copyWith method
/// - Proper equality and hashCode implementation
/// - Data validation for business rules
@JsonSerializable()
class User {
  /// Unique identifier for the user
  final int id;
  
  /// User's display name (2+ characters)
  final String name;
  
  /// User's email address (must be valid format)
  final String email;
  
  /// Timestamp when user was created
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// Timestamp when user was last updated
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Constructor for User model
  /// All fields are required and final for immutability
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create User from JSON map
  /// Used for deserializing API responses or stored data
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  /// Convert User to JSON map
  /// Used for serializing data for API requests or storage
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Create a copy of this User with optional field updates
  /// Returns a new User instance with specified fields changed
  /// This maintains immutability while allowing updates
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

  /// Equality operator for User comparison
  /// Two users are equal if all their fields are equal
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

  /// Hash code implementation for User
  /// Used in collections like Set and Map
  /// Combines hash codes of all fields using XOR operation
  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  /// String representation of User
  /// Useful for debugging and logging
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// CreateUserRequest represents the payload for creating a new user
/// This model is used for API requests and input validation
/// 
/// Features:
/// - JSON serialization for API communication
/// - Data validation for business rules
/// - Clean separation between request and domain models
@JsonSerializable()
class CreateUserRequest {
  /// User's display name (2+ characters required)
  final String name;
  
  /// User's email address (must be valid format)
  final String email;

  /// Constructor for CreateUserRequest
  /// Both fields are required for user creation
  CreateUserRequest({
    required this.name,
    required this.email,
  });

  /// Create CreateUserRequest from JSON map
  /// Used for deserializing API request bodies
  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
      
  /// Convert CreateUserRequest to JSON map
  /// Used for serializing API request bodies
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);

  /// Validate the request data
  /// Returns true if data meets business rules, false otherwise
  /// 
  /// Validation rules:
  /// - Name must be at least 2 characters long
  /// - Email must match valid email format
  bool validate() {
    // Name validation: must be at least 2 characters
    if (name.trim().length < 2) {
      return false;
    }
    
    // Email validation: must match email format
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!emailRegex.hasMatch(email.trim())) {
      return false;
    }
    
    return true;
  }
}
