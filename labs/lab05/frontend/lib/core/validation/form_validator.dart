class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'email is required';
    }
    final trimmed = email.trim();
    if (trimmed.length > 100) {
      return 'email is too long';
    }
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'invalid email format';
    }
    return null;
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'password is required';
    }
    if (password.length < 6) {
      return 'password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasDigit) {
      return 'password must contain letter and number';
    }
    return null;
  }

  // sanitizeText removes basic dangerous characters and tags
  static String sanitizeText(String? text) {
    if (text == null) return '';
    // remove any <...> tags completely
    final withoutTags = text.replaceAll(RegExp(r'<.*?>'), '');
    return withoutTags.trim();
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final len = text.length;
    return len >= minLength && len <= maxLength;
  }
}