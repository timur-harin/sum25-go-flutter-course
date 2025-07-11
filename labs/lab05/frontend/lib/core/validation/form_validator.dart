// Simple form validation with basic security checks

class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null) {
      return "Email is required";
    } else {
      if (email == "") {
        return "Email is required";
      } else if (email.length > 100) {
        return "Email is too long";
      } else if (!email.contains("@") || !email.contains(".")) {
        return "invalid email";
      } else {
        return null;
      }
    }
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "password is required";
    }
    if(password.length < 6) {
      return "password to have at least 6 characters";
    } else {
      final letter = password.contains(RegExp(r'[A-Za-z]'));
      final number = password.contains(RegExp(r'[0-9]'));
      if (!letter || !number) {
        return "contains at least one letter and number";
      }
    }
  }

  static String sanitizeText(String? text) {
    if (text == null) {
      return "";
    } else {
      text = text.replaceAll(RegExp(r'<[^>]*>'), "");
      text = text.replaceAll('>', '').replaceAll('<', '');
      text = text.trim();
      return text;
    }
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false;
    } else {
      if (text.length < minLength || text.length > maxLength) {
        return false;
      }
      return true;
    }
  }
}
