// Simple form validation with basic security checks

import 'dart:ffi';

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null) {
      return "required";
    }
    email = email.trim();
    email = email.toLowerCase();
    if (email.isEmpty) {
      return "required";
    }
    if (!email.contains("@") || !email.contains(".")) {
      return "invalid email";
    }
    if (email.length > 100) {
      return "too long email";
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null) {
      return "required";
    }
    if (password.isEmpty) {
      return "required";
    }
    if (password.length < 6) {
      return "6 characters";
    }

    final letters = [
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
      'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ];

    bool hasLetter = false;

    for (int i = 0; i < password.length; i++) {
      for (int j = 0; j < letters.length; j++) {
        if (password[i] == letters[j]) {
          hasLetter = true;
          break;
        }
      }
      if (hasLetter) {
        break;
      }
    }

    if (!hasLetter) {
      return "letter and number";
    }

    final digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    bool hasDigit = false;

    for (int i = 0; i < password.length; i++) {
      for (int j = 0; j < digits.length; j++) {
        if (password[i] == digits[j]) {
          hasDigit = true;
          break;
        }
      }
      if (hasDigit) {
        break;
      }
    }

    if (!hasDigit) {
      return "letter and number";
    }

    return null;
  }

  static String sanitizeText(String? text) {
    if (text == null) {
      return "";
    }

    String sanitizedText = "";
    bool foundBadCharacter = false;
    for (int i = 0; i < text.length; i++) {
      String symbol = text[i];
      if (symbol == "<") {
        foundBadCharacter = true;
      }
      else if (symbol == ">") {
        foundBadCharacter = false;
      }
      else {
        if (!foundBadCharacter) {
          sanitizedText += symbol;
        }
      }
    }

    sanitizedText = sanitizedText.trim();

    return sanitizedText;
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
