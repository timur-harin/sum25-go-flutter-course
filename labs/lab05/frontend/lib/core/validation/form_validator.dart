// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email == "") {
      return "required email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "invalid email format";
    }
    if (email.length > 100) {
      return "email too long";
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password == "") {
      return "required password";
    }
    if (password.length < 6) {
      return "password must contain at least 6 characters";
    }

    final hasLetter = RegExp(r'[A-Za-z]');
    final hasDigit = RegExp(r'\d');

    if (hasLetter.hasMatch(password) == false ||
        hasDigit.hasMatch(password) == false) {
      return "password should contain letter and number";
    }
    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null || text == "") {
      return "";
    }
    final tagRegex = RegExp(r'<[^>]*>');
    return text.replaceAll(tagRegex, '').trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null || text == "") {
      return false;
    }
    return text.length <= maxLength && text.length >= minLength;
  }
}
