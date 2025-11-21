// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (email.length > 100) {
      return 'Email is too long';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
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
      return 'Password must contain a letter and number';
    }
    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) return '';
    // Удалить всё между <...>
    final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleaned.trim();
  }

  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    return text.length >= minLength && text.length <= maxLength;
  }
}
