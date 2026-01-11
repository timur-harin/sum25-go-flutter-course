class FormValidator {
  // validateEmail checks if an email is valid
  // Requirements:
  // - return null for valid emails
  // - return error message for invalid emails
  // - check basic email format (contains @ and .)
  // - check reasonable length (max 100 characters)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'email is required';
    }
    final sanitized = email.trim();
    if (sanitized.length > 100) {
      return 'email is too long';
    }
    if (!sanitized.contains('@') || !sanitized.contains('.')) {
      return 'invalid email format';
    }
    return null;
  }

  // validatePassword checks if a password is valid
  // Requirements:
  // - return null for valid passwords
  // - return error message for invalid passwords
  // - check for null/empty, length >=6, contains letter and number
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'password is required';
    }
    if (password.length < 6) {
      return 'password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return 'password must contain at least one letter and number';
    }
    return null;
  }

  // sanitizeText removes HTML-like tags and trims whitespace
  // Requirements:
  // - remove any <...> sequences
  // - trim whitespace
  // - handle null gracefully
  static String sanitizeText(String? text) {
    if (text == null) return '';
    final withoutTags = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags.trim();
  }

  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}