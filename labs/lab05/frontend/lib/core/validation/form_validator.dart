// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmed = email.trim();

    if (trimmed.length > 100) {
      return 'Email is too long';
    }

    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Email format is invalid';
    }

    return null; // valid
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'Must contain letter and number';
    }

    return null; // valid
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return cleaned;
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    return text.length >= minLength && text.length <= maxLength;
  }
}
