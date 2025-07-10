class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailTrimmed = email.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(emailTrimmed)) {
      return 'invalid email format';
    }

    if (emailTrimmed.length > 100) {
      return 'email is too long (max 100 characters)';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'password is required';
    }

    if (password.length < 6) {
      return 'password must be at least 6 characters long';
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'password must contain at least one letter and number';
    }

    return null;
  }

  static String sanitizeText(String? text) {
  if (text == null) {
    return '';
  }
  return text.replaceAll(RegExp(r'<.*?>'), '').trim(); 
}

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    }
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}