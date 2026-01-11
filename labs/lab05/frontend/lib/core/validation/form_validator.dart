class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length > 100) {
      return 'Email is too long (max 100 characters)';
    }

    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return 'invalid email format';
    }

    if (trimmedEmail.indexOf('@') > trimmedEmail.lastIndexOf('.')) {
      return 'invalid email format';
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
    
    final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    final fullyCleaned = cleaned.replaceAll(RegExp(r'[<>]'), '');
    return fullyCleaned.trim();
  }

  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}