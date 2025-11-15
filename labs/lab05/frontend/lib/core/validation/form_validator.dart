// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
     if (email == null || email.trim().isEmpty) {
      return "Email is required";
     }
     
    final trimEmail = email.trim();

    if (trimEmail.length >= 100) {
      return 'invalid email: Email is too long';
    }
    if (!trimEmail.contains('@')) {
      return 'invalid email: Email must contain @';
    }
    if (!trimEmail.contains('.') || trimEmail.endsWith('@')) {
      return 'invalid email: Email must have valid domain';
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
    if (!password.contains(RegExp(r'[A-Za-z]')) || !password.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least one letter and number';
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';
    return text.replaceAll('<script>', '').replaceAll('<', '').replaceAll('>', '').trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    return text.length >= minLength && text.length <= maxLength;
  }
}