// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    final cleanEmail = sanitizeText(email);

    if (cleanEmail == null || cleanEmail == "") {
      return "Email required";
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',);
    if (!emailRegex.hasMatch(cleanEmail)) {
      return "Email format is invalid";
    }

    if (cleanEmail.length > 100) {
      return "Email is too long";
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password required";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters long";
    }

    final lettersRegex = RegExp(r'[A-Za-z]');
    final numbersRegex = RegExp(r'[0-9]');
    if (!lettersRegex.hasMatch(password!) || 
      !numbersRegex.hasMatch(password!)) {
        return "Password must contain at least one letter and number";
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) {
      return '';
    }

    final trimmedText = text.trim();
    final cleanText = trimmedText.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleanText;
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    }

    if (text.length < minLength || text.length > maxLength) {
      return false;
    }

    return true;
  }
}
