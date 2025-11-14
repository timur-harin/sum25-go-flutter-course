// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (email.length > 100) {
      return 'Email is too long';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email format is invalid';
    }
    return null;
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'Password must contain letter and number';
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
  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}