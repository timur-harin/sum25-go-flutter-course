// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (email == null || email.isEmpty) {
      return "required email must be not empty";
    }
    if (!emailRegex.hasMatch(email)) {
      return "email is invalid";
    }
    if (email.length > 100) {
      return "email is too long";
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "required password must not be empty";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (!password.contains(RegExp(r'[a-zA-Z]')) || !password.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one letter and number";
    }
    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) {
      return "";
    }
    text = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return text;
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    }
    if (text.length >= minLength && text.length <= maxLength) {
      return true;
    }
    return false;
  }
}
