// Simple form validation with basic security checks

class FormValidator {
  // TODO: Implement validateEmail method
  // validateEmail checks if an email is valid
  // Requirements:
  // - return null for valid emails
  // - return error message for invalid emails
  // - check basic email format (contains @ and .)
  // - check reasonable length (max 100 characters)
  static String? validateEmail(String? email) {
    if (email == null || email == "") {
      return "required";
    } else if (!isValidLength(email, maxLength: 100)) {
      return "too long";
    }
     final regex = RegExp(
    r"^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$"
  );
    if (!regex.hasMatch(email)) {
      return "invalid";
    }
    // TODO: Implement email validation
    // Check for null/empty, basic format, and length
    return null;
  }

  // TODO: Implement validatePassword method
  // validatePassword checks if a password meets basic requirements
  // Requirements:
  // - return null for valid passwords
  // - return error message for invalid passwords
  // - minimum 6 characters
  // - contains at least one letter and one number
  static String? validatePassword(String? password) {
    if (password == null || password == "") {
      return "required";
    } else if (!isValidLength(password, minLength: 6)) {
      return "6 characters";
    } else if ( !RegExp(r'\d').hasMatch(password) || !RegExp(r'[A-Za-z]').hasMatch(password)) {
      return "letter and number";
    }
    return null;
  }

  // TODO: Implement sanitizeText method
  // sanitizeText removes basic dangerous characters
  // Requirements:
  // - remove < and > characters
  // - trim whitespace
  // - return cleaned text
  static String sanitizeText(String? text) {
    if (text == null) return '';
    final cleared = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return cleared;
  }

  // TODO: Implement isValidLength method
  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null || text.length < minLength || text.length > maxLength) {
      return false;
    }
    return true;
  }
}
