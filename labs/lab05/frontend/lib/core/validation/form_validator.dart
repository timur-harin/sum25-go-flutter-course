// Simple form validation with basic security checks
class FormValidator {
  // validateEmail checks if an email is valid
  static String? validateEmail(String? email) {
    // Check for null or empty email
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    // Check length limit
    if (email.length > 100) {
      return 'Email is too long';
    }

    // Check basic email format (contains @ and .)
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email is invalid';
    }

    // Additional basic format checks
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email is invalid';
    }

    return null; // Valid email
  }

  // validatePassword checks if a password meets basic requirements
  static String? validatePassword(String? password) {
    // Check for null or empty password
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length (6 characters)
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }

    return null; // Valid password
  }

  // sanitizeText removes basic dangerous characters
  static String sanitizeText(String? text) {
    // Handle null text
    if (text == null) {
      return '';
    }

    // Remove complete HTML tags and trim whitespace
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove complete HTML tags
        .trim();
  }

  // isValidLength checks if text is within length limits
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    // Handle null text gracefully
    if (text == null) {
      return minLength == 0;
    }

    // Check if text length is between min and max
    return text.length >= minLength && text.length <= maxLength;
  }
}
