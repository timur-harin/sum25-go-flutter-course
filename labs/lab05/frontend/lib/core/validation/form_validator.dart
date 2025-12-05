class FormValidator {

  static String? validateEmail(String? email) {
    // Check for null or empty input
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Trim whitespace and verify not empty after trimming
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'Email is required';
    }

    // Check maximum length
    if (trimmedEmail.length > 100) {
      return 'Email is too long (max 100 characters)';
    }

    // Basic format checks before regex validation
    if (!trimmedEmail.contains('@')) {
      return 'invalid email format';
    }

    if (!trimmedEmail.contains('.')) {
      return 'invalid email format';
    }

    // Comprehensive email regex validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'invalid email format';
    }

    return null; // Return null when validation passes
  }

  static String? validatePassword(String? password) {
    // Check for null or empty input
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length requirement
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for presence of at least one letter and one number
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }

    return null; // Return null when validation passes
  }

  static String sanitizeText(String? text) {
    if (text == null) return '';

    // Remove all HTML tags and their content
    final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Trim whitespace from the result
    return cleaned.trim();
  }

  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}