// Simple form validation with basic security checks

class FormValidator {
  /// validateEmail
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    // Простая проверка на формат email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Email format is invalid';
    }

    if (trimmedEmail.length > 100) {
      return 'Email is too long';
    }

    return null; // valid email
  }

  /// validatePassword
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }

    return null; // valid password
  }

  /// sanitizeText
  static String sanitizeText(String? text) {
  if (text == null) return '';
  final withoutTags = text.replaceAll(RegExp(r'<[^>]*>'), '');
  return withoutTags.trim();
}

  /// isValidLength
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
