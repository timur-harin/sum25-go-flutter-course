import 'package:equatable/equatable.dart';

/// User represents a user entity in the domain layer
/// This class follows Clean Architecture principles and implements
/// value equality through Equatable
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, name, email, createdAt];

  /// Creates a copy of this User with optionally updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validates email format using regex pattern
  bool isValidEmail() {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Validates name is between 2-51 characters and not empty
  bool isValidName() {
    final trimmedName = name.trim();
    return trimmedName.isNotEmpty &&
        trimmedName.length >= 2 &&
        trimmedName.length <= 51;
  }

  /// Validates ID is positive
  bool isValidId() {
    return id > 0;
  }

  /// Validates createdAt is not in the future
  bool isValidCreatedAt() {
    return createdAt.isBefore(DateTime.now()) ||
        createdAt.isAtSameMomentAs(DateTime.now());
  }

  /// Validates all fields are valid
  bool isValid() {
    return isValidEmail() && isValidName() && isValidId() && isValidCreatedAt();
  }

  /// Factory constructor for creating User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Provides string representation for debugging
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, createdAt: $createdAt}';
  }
}
