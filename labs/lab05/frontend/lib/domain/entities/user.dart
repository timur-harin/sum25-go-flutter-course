import 'package:equatable/equatable.dart';


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

  bool isValidEmail() {
    // Check for empty email
    if (email.isEmpty) return false;

    // Define comprehensive email validation pattern
    RegExp emailValidationRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Test email against pattern
    return emailValidationRegex.hasMatch(email);
  }

  bool isValidName() {
    // Clean name by removing surrounding whitespace
    String cleanName = name.trim();
    
    // Check name constraints
    return cleanName.isNotEmpty &&
        cleanName.length >= 2 &&
        cleanName.length <= 51;
  }

  bool isValid() {
    // User is valid if both email and name pass validation
    return isValidEmail() && isValidName();
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, createdAt: $createdAt}';
  }
}