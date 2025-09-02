// Simple form validation with basic security checks

class FormValidator {
  // validateEmail checks if an email is valid
  // Requirements:
  // - return null for valid emails
  // - return error message for invalid emails
  // - check basic email format (contains @ and .)
  // - check reasonable length (max 100 characters)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length > 100) {
      return 'Email is too long';
    }

    // Basic email format check - must contain @ and .
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return 'Email is invalid';
    }

    // More thorough email regex
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Email is invalid';
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
      return 'Password must be at least 6 characters';
    }

    // Check for at least one letter
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    if (!hasLetter) {
      return 'Password must contain letter and number';
    }

    // Check for at least one number
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasNumber) {
      return 'Password must contain letter and number';
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
      return '';
    }

    // Remove content between < and > (including the brackets)
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Trim whitespace
    return cleaned.trim();
  }

  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) {
      return minLength == 0;
    }

    return text.length >= minLength && text.length <= maxLength;
  }
}
