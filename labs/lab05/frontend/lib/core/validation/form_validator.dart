class FormValidator {
  // Validate email format and length
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length > 100) {
      return 'Email is too long';
    }

    // Basic format check: contains '@' and '.'
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return 'Email format is invalid';
    }

    // Simple regex for basic email validation (optional)
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Email format is invalid';
    }

    return null; // valid email
  }

  // Validate password complexity and length
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = password.contains(RegExp(r'\d'));

    if (!hasLetter || !hasNumber) {
      return 'letter and number';
    }

    return null; // valid password
  }

  // Remove dangerous characters and trim whitespace
  static String sanitizeText(String? text) {
    if (text == null) {
      return '';
    }

    final tagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    final cleaned = text.replaceAll(tagRegExp, '');

    return cleaned.trim();
  }

  // Check if text length is within min and max bounds
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    }

    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
