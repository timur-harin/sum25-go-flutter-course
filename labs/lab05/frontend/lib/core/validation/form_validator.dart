
class FormValidator {
  // validateEmail checks if an email is valid
  // Returns null for valid emails or an error message otherwise
  // Performs basic format and length checks
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final cleaned = email.trim();

    if (cleaned.length > 100) {
      return 'Email is too long';
    }

    // Basic format check
    if (!cleaned.contains('@') || !cleaned.contains('.')) {
      return 'Email is invalid';
    }

    return null;
  }

  // validatePassword ensures a password meets basic requirements.
  // Returns null for valid passwords or an error message otherwise.
  // The password must be at least 6 characters and include at least
  // one letter and one number.
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
      return 'Password must contain a letter and number';
    }

    return null;
  }

  // sanitizeText removes potentially dangerous characters and
  // trims surrounding whitespace.
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    var cleaned = text.replaceAll(RegExp(r'<[^>]+>'), '');
    cleaned = cleaned.trim();
    return cleaned;
  }

  // isValidLength checks if text is within provided length limits.
  // Returns true when the text length is between min and max bounds.
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
