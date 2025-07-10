// Simple form validation with basic security checks

class FormValidator {
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
    return null;
  }

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
      return 'Password must contain at least one letter and number';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      return 'Name is too short';
    }
    if (trimmed.length > 50) {
      return 'Name is too long';
    }
    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';
    // Remove all content between <...>
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final len = text.length;
    return len >= minLength && len <= maxLength;
  }
}
