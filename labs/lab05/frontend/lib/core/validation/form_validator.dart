// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final value = email.trim();
    if (value.length > 100) {
      return 'Email is too long';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'invalid email format';
    }
    return null;
  }

  // validatePassword checks if a password meets basic requirements
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
    return null;
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
