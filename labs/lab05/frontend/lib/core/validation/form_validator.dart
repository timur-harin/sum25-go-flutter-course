// Simple form validation with basic security checks

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';

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
    if (email == null) {
      return "required email can not be null";
    }
    if (!email.contains("@") || !email.contains(".")) {
      return "invalid email: required @ and .";
    }
    if (email.length >= 100) {
      return "invalid email: too long, it should be less then 100";
    }
    if (email.length <= 0) {
      return "invalid email: invalid size for required email. It should be greater than 0 and less then 100";
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
    if (password == null) {
      return "required password";
    }
    if (password.length < 6) {
      return "required password should be at least 6 characters";
    }

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return "password should contain letter and number";
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
    if (text == null) {
      return '';
    }
    String cleanedText = text.replaceAll(RegExp('<[^>]*>'), '');
    cleanedText = cleanedText.trim();
    return cleanedText;
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
    if (text.length < minLength || text.length > maxLength) return false;
    return true;
  }
}
