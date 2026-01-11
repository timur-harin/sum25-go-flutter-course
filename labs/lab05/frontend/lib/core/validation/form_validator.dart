// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final trimmed = email.trim();
    if (trimmed.length > 100) return 'Email is too long';
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Email format is invalid';
    }
    return null;
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    final trimmed = password?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Password is required';
    }
    if (trimmed.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = trimmed.contains(RegExp(r'[a-zA-Z]'));

    final hasDigit = trimmed.contains(RegExp(r'\d'));

    if (!hasDigit || !hasLetter) {
      return 'Password must contain at least one letter and number';
    }
    return null;
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) return '';
    final withoutTags = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags.trim();
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    if (text.length < minLength || text.length > maxLength) return false;
    return true;
  }
}
