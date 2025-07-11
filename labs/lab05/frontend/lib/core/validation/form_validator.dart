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
    // TODO: Implement email validation
    // Check for null/empty, basic format, and length
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmedEmail = email.trim();
    if (trimmedEmail.length > 100) {
      return 'Email is too long';
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return 'Email is invalid';
    }
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
    // TODO: Implement password validation
    // Check length and basic complexity
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return 'Password must include a letter and number';
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
    // TODO: Implement text sanitization
    // Clean basic dangerous characters
    if (text == null) return '';
    return text?.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('<', '').replaceAll('>', '').trim() ?? '';

  }

  // TODO: Implement isValidLength method
  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    // TODO: Implement length validation
    // Check text length bounds
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
