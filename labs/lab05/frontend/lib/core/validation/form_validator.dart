class FormValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (email.length > 100) {
      return 'Email is too long';
    }
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!emailRegex.hasMatch(email)) {
      return 'invalid email format';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    final letterRegex = RegExp(r'[A-Za-z]');
    final numberRegex = RegExp(r'\d');
    if (!letterRegex.hasMatch(password) || !numberRegex.hasMatch(password)) {
      return 'Password must contain both letter and number';
    }
    return null;
  }

  static String sanitizeText(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('<script>', '')
        .replaceAll('</script>', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .trim();
  }

  static bool isValidLength(String? input, {required int minLength, required int maxLength}) {
    if (input == null) return false;
    return input.length >= minLength && input.length <= maxLength;
  }
}