class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final sanitizedEmail = sanitizeText(email);

    if (!isValidLength(sanitizedEmail, maxLength: 100)) {
      return 'Email is too long';
    }

    if (!sanitizedEmail.contains('@') || !sanitizedEmail.contains('.')) {
      return 'invalid email';
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

    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';

    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    return text.length >= minLength && text.length <= maxLength;
  }
}
