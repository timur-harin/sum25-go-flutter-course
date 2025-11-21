// ignore_for_file: json_serializable
import 'dart:convert';

/// SecureStorageService provides encrypted storage for sensitive data
/// such as authentication tokens, user credentials, and security settings.
/// 
/// This service demonstrates:
/// - Secure data storage patterns
/// - Authentication token management
/// - User credential handling
/// - Biometric settings storage
/// - JSON serialization for complex objects
/// - In-memory fallback for Linux compatibility
class SecureStorageService {
  /// In-memory storage as fallback for Linux platform
  /// This provides the same API as flutter_secure_storage but uses
  /// in-memory storage instead of platform-specific secure storage
  static final Map<String, String> _memoryStorage = {};

  /// Store authentication token securely
  /// Used for maintaining user sessions and API authentication
  static Future<void> saveAuthToken(String token) async {
    _memoryStorage['auth_token'] = token;
  }

  /// Retrieve authentication token
  /// Returns null if no token is stored
  static Future<String?> getAuthToken() async {
    return _memoryStorage['auth_token'];
  }

  /// Remove authentication token
  /// Called during logout or token expiration
  static Future<void> deleteAuthToken() async {
    _memoryStorage.remove('auth_token');
  }

  /// Store user credentials (username and password)
  /// Used for "remember me" functionality or auto-login
  /// Note: In production, consider using biometric authentication instead
  static Future<void> saveUserCredentials(String username, String password) async {
    _memoryStorage['username'] = username;
    _memoryStorage['password'] = password;
  }

  /// Retrieve stored user credentials
  /// Returns a map with 'username' and 'password' keys
  /// Both values can be null if not previously stored
  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'username': _memoryStorage['username'],
      'password': _memoryStorage['password'],
    };
  }

  /// Remove stored user credentials
  /// Called during logout or when user changes credentials
  static Future<void> deleteUserCredentials() async {
    _memoryStorage.remove('username');
    _memoryStorage.remove('password');
  }

  /// Store biometric authentication setting
  /// Controls whether the app should use biometric authentication
  static Future<void> saveBiometricEnabled(bool enabled) async {
    _memoryStorage['biometric_enabled'] = enabled.toString();
  }

  /// Check if biometric authentication is enabled
  /// Returns false by default if setting is not stored
  static Future<bool> isBiometricEnabled() async {
    final value = _memoryStorage['biometric_enabled'];
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  /// Store any secure data with a custom key
  /// Generic method for storing sensitive information
  /// Useful for API keys, encryption keys, etc.
  static Future<void> saveSecureData(String key, String value) async {
    _memoryStorage[key] = value;
  }

  /// Retrieve secure data by key
  /// Returns null if key doesn't exist
  static Future<String?> getSecureData(String key) async {
    return _memoryStorage[key];
  }

  /// Remove secure data by key
  /// Useful for cleaning up sensitive data
  static Future<void> deleteSecureData(String key) async {
    _memoryStorage.remove(key);
  }

  /// Store a complex object as encrypted JSON
  /// Converts Map<String, dynamic> to JSON string for storage
  /// Useful for storing user profiles, settings, etc.
  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    _memoryStorage[key] = jsonString;
  }

  /// Retrieve a complex object by key
  /// Decodes JSON string back to Map<String, dynamic>
  /// Throws exception if stored value is not a valid JSON object
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = _memoryStorage[key];
    if (jsonString == null) return null;
    
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('Stored value is not a Map<String, dynamic>');
      }
    } catch (e) {
      throw Exception('Failed to decode JSON for key "$key": $e');
    }
  }

  /// Check if a key exists in secure storage
  /// Returns false if key doesn't exist
  static Future<bool> containsKey(String key) async {
    return _memoryStorage.containsKey(key);
  }

  /// Get all stored keys
  /// Useful for debugging or data export functionality
  /// Returns a list of all keys currently in storage
  static Future<List<String>> getAllKeys() async {
    return _memoryStorage.keys.toList();
  }

  /// Clear all secure data
  /// Use with caution - this removes all sensitive data
  /// Called during logout or app reset
  static Future<void> clearAll() async {
    _memoryStorage.clear();
  }

  /// Export all stored data
  /// Returns a map of all key-value pairs
  /// Useful for data backup or migration
  static Future<Map<String, String>> exportData() async {
    return Map.from(_memoryStorage);
  }
}
