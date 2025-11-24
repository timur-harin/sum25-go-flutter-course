// Simple form validation with basic security checks

class FormValidator {
  // TODO: Implement validateEmail method
  // validateEmail checks if an email is valid
  // Requirements:
  // - return null for valid emails
  // - return error message for invalid emails
  // - check basic email format (contains @ and .)
  // - check reasonable length (max 100 characters)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = email.trim();
    if (trimmed.length > 100) {
      return 'Email is too long';
    }
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Email is invalid';
    }
    // Простейшая проверка на корректность
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+*$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email is invalid';
    }
    return null;
  }

  // TODO: Implement validatePassword method
  // validatePassword checks if a password meets basic requirements
  // Requirements:
  // - return null for valid passwords
  // - return error message for invalid passwords
  // - minimum 6 characters
  // - contains at least one letter and one number
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasNumber) {
      return 'Password must contain a letter and number';
    }
    return null;
  }

  // TODO: Implement sanitizeText method
  // sanitizeText removes basic dangerous characters
  // Requirements:
  // - remove < and > characters
  // - trim whitespace
  // - return cleaned text
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) return '';
    var cleaned = text.replaceAll('<', '').replaceAll('>', '');
    return cleaned.trim();
  }

  // TODO: Implement isValidLength method
  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final len = text.length;
    return len >= minLength && len <= maxLength;
  }
}
