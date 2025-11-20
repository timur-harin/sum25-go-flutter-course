// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmed = email.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Email is invalid';
    }

    if (trimmed.length > 100) {
      return 'Email is too long';
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

    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasLetter || !hasNumber) {
      return 'Password must contain a letter and number';
    }

    return null;
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
  if (text == null || text.isEmpty) return '';
  final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
  return cleaned.trim();
}
  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}