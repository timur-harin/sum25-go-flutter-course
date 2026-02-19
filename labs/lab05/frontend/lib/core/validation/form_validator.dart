// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    // Check for email being null
    if (email == null || email.length == 0) {
      return "required";
    }

    // Check the email length
    int maxEmailLength = 100;
    if (email.length > maxEmailLength) {
      return "too long email";
    }

    // Check the format
    if (!email.contains("@", 0) || !email.contains('.')) {
      return "invalid email format";
    }

    // OK, valid email
    return null;
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    // Check the password for being null
    if (password == null || password.length == 0) {
      return "required";
    }

    // Check the length of the password
    int minPasswordLength = 6;
    if (password.length < minPasswordLength) {
      return "password should be at least 6 characters in length";
    }

    // Check for the needed symbols in the password
    String digits = "1234567890";
    String letters = "qwertyuiopasdfghjklzxcvbnmQWRTYUIOPASDFGHJKLXCVBNM";

    bool containsDigit = false;
    bool containsLetter = false;
    for (int i = 0; i < password.length; ++i) {
      // Check the password for containing a letter
      for (int let = 0; let < letters.length; ++let) {
        containsLetter |= (password[i] == letters[let]);
      }

      // Check the password for containing a digit
      for (int dig = 0; dig < digits.length; ++dig) {
        containsDigit |= (password[i] == digits[dig]);
      }
    }

    // Final check
    if (!containsLetter || !containsDigit) {
      return "password should contain a letter and number";
    }

    // OK, password is valid
    return null;
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    if (text == null) {
      // Nothing to do -> return empty text
      return "";
    }

    // Remove dangerous symbols
    // Author: Magomedgadzhi Ibragimov
    text = text.trim();
    String sanitizedText = "";
    bool foundBadCharacter = false;
    for (int i = 0; i < text.length; i++) {
      String symbol = text[i];
      if (symbol == "<") {
        foundBadCharacter = true;
      } else if (symbol == ">") {
        foundBadCharacter = false;
      } else {
        if (!foundBadCharacter) {
          sanitizedText += symbol;
        }
      }
    }

    return sanitizedText;
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    // Check for the text being null
    if (text == null) {
      return false;
    }

    // Check for the text length being valid
    if (text.length < minLength || text.length > maxLength) {
      return false;
    }

    // OK, valid text
    return true;
  }
}
