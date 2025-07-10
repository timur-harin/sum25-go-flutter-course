class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'email is required';
    }

    // Trim and sanitize email
    final sanitizedEmail = sanitizeText(email);
    if (sanitizedEmail.isEmpty) {
      return 'email is required';
    }

    // Basic email format validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(sanitizedEmail)) {
      return 'invalid email format';
    }

    // Length validation
    if (!isValidLength(sanitizedEmail, maxLength: 100)) {
      return 'email is too long';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'password is required';
    }

    // Length validation
    if (!isValidLength(password, minLength: 6)) {
      return 'password must be at least 6 characters';
    }

    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'password must contain letter and number';
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';

    // Remove < and > characters and anything between them
    final sanitized = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Trim whitespace
    return sanitized.trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    return text.length >= minLength && text.length <= maxLength;
  }
}
