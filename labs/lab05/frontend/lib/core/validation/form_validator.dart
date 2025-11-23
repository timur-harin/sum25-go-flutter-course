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
      return 'Email is too long (max 100 characters)';
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email format is invalid';
    }
    
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Email format is invalid';
    }
    
    final localPart = parts[0];
    final domainPart = parts[1];
    
    if (localPart.isEmpty || domainPart.isEmpty) {
      return 'Email format is invalid';
    }
    
    if (!domainPart.contains('.')) {
      return 'Email format is invalid';
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
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    
    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }
    
    return null;
  }

  // sanitizeText removes basic dangerous characters
  // Requirements:
  // - remove < and > characters
  // - trim whitespace
  // - return cleaned text
  static String sanitizeText(String? text) {
    if (text == null) return '';
    
    // Remove content between < and > tags
    var result = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Trim whitespace
    result = result.trim();
    
    return result;
  }

  // isValidLength checks if text is within length limits
  // Requirements:
  // - return true if text length is between min and max
  // - handle null text gracefully
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
