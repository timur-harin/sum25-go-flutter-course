// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  // Requirements:
  // - return null for valid emails
  // - return error message for invalid emails
  // - check basic email format (contains @ and .)
  // - check reasonable length (max 100 characters)
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 100) {
      return 'Email too long';
    }

    final emailRegex = RegExp(r'^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'email is invalid';
    }
    return null;
  }

  // validatePassword checks if a password meets basic requirements
  // Requirements:
  // - return null for valid passwords
  // - return error message for invalid passwords
  // - minimum 6 characters
  // - contains at least one letter and one number
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password should have minimum 6 characters';
    }

    if (!password.contains(new RegExp(r'[a-z]'))) {
      return 'Password should contains at least one letter and number';
    }
    if (!password.contains(new RegExp(r'[0-9]'))) {
      return 'Password should contains at least one letter and number';
    }

    return null;
  }

  // sanitizeText removes basic dangerous characters
  // Requirements:
  // - remove < and > characters
  // - trim whitespace
  // - return cleaned text
  static String sanitizeText(String? text) {
    if (text == null) {
      return "";
    }
    return text.replaceAll(RegExp("<.*>"), "").trim();
  }

  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return false; // Null text is not valid
    }
    return text.length >= minLength && text.length <= maxLength;
  }
}
