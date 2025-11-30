class FormValidator {

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final sanitized = email.trim();
    if (sanitized.length > 100) {
      return 'Email is too long';
    }
    if (!sanitized.contains('@') || !sanitized.contains('.')) {
      return 'Email is invalid';
    }
    return null;
  }

 
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and number';
    }
    return null;
  }

 
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }
   
    final withoutTags = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags.trim();
  }

  
  static bool isValidLength(String? text,
      {int minLength = 1, int maxLength = 100}) {
    if (text == null) return false;
    final length = text.length;
    return length >= minLength && length <= maxLength;
  }
}
