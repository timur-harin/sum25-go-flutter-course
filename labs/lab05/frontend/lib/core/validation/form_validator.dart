class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 100) {
      return 'Email is too long (max 100 characters)';
    }

    final atIndex = email.indexOf('@');
    if (atIndex == -1 || atIndex == 0 || atIndex == email.length - 1) {
      return 'invalid';
    }

    final domain = email.substring(atIndex + 1);
    if (!domain.contains('.')) {
      return 'invalid';
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
      return 'letter and number';
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
