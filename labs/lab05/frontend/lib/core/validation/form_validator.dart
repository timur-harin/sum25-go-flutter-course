// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = email.trim();
    if (trimmed.length > 100) {
      return 'Email is too long (max 100 characters)';
    }
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Email is invalid';
    }
    // Basic regex for email
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+*');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email is invalid';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return 'Password must contain letter and number';
    }
    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';
    // Remove <...> tags and their content
    var cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleaned.trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final len = text.length;
    return len >= minLength && len <= maxLength;
  }
}
