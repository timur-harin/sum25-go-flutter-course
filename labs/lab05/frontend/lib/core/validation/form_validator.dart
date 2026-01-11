// Simple form validation with basic security checks

import 'dart:collection';

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (!email.contains("@") || !email.contains(".")) {
      return "does not contain 'invalid'";
    }

    if (!isValidLength(email, maxLength: 100)) {
      return "does not contain 'too long'";
    }

    return null;
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    bool hasLetter = false;
    bool hasNumber = false;

    for (var char in password.runes) {
      if (!hasLetter && (char >= 65 && char <= 90) || (char >= 97 && char <= 122)) {
        hasLetter = true;
      }
      if (!hasNumber && char >= 48 && char <= 57) {
        hasNumber = true;
      }

      if (hasLetter && hasNumber) {
        break;
      }
    }

      if (!hasLetter || !hasNumber) {
        return "contains 'letter and number'";
      }
    return null;
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    if (text == null) {
      return "";
    }

    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    }

    return text.length >= minLength && text.length <= maxLength;
  }
}
