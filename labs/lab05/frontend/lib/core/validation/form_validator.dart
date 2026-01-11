class FormValidator {
  static String? _validateEmail(String? email) {
    // Check for null or empty input
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Clean whitespace and check length
    String cleanedEmail = email.trim();
    if (cleanedEmail.length > 100) {
      return 'Email is too long';
    }
    
    // Basic format validation
    if (!cleanedEmail.contains('@') || !cleanedEmail.contains('.')) {
      return 'invalid email format';
    }
    
    // Advanced regex validation
    RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ *');
    if (!emailPattern.hasMatch(cleanedEmail)) {
      return 'invalid email format';
    }
    
    return null;
  }

  static String? _validatePassword(String? password) {
    // Check for null or empty password
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    // Minimum length requirement
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    // Check for letter requirement
    bool containsLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    // Check for number requirement
    bool containsNumber = RegExp(r'[0-9]').hasMatch(password);
    
    if (!containsLetter || !containsNumber) {
      return 'Password must contain at least one letter and number';
    }
    
    return null;
  }


  static String sanitizeText(String? text) {
    if (text == null) return '';
    
    // Remove HTML tags from input
    String cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Trim whitespace
    return cleanText.trim();
  }

  static bool isValidLength(String? text, {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    
    int textLength = text.length;
    return textLength >= minLength && textLength <= maxLength;
  }

  static String? validateEmail(String? email) {
    return _validateEmail(email);
  }

  static String? validatePassword(String? password) {
    return _validatePassword(password);
  }
}