// ignore_for_file: json_serializable
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// PreferencesService provides a simple key-value storage solution
/// using SharedPreferences for non-sensitive data like user settings,
/// app configuration, and cached data.
/// 
/// This service demonstrates:
/// - Simple key-value storage patterns
/// - Type-safe data operations
/// - Error handling for uninitialized state
/// - JSON serialization for complex objects
class PreferencesService {
  /// Static instance of SharedPreferences for singleton pattern
  /// This ensures we have a single instance across the app
  static SharedPreferences? _prefs;

  /// Initialize the SharedPreferences instance
  /// Must be called before any other operations
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Store a string value with the given key
  /// Throws exception if SharedPreferences is not initialized
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.setString(key, value);
  }

  /// Retrieve a string value by key
  /// Returns null if key doesn't exist or SharedPreferences is not initialized
  static String? getString(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.getString(key);
  }

  /// Store an integer value with the given key
  /// Useful for storing numeric settings like theme mode, language index, etc.
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.setInt(key, value);
  }

  /// Retrieve an integer value by key
  /// Returns null if key doesn't exist
  static int? getInt(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.getInt(key);
  }

  /// Store a boolean value with the given key
  /// Perfect for feature flags, settings toggles, etc.
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.setBool(key, value);
  }

  /// Retrieve a boolean value by key
  /// Returns null if key doesn't exist
  static bool? getBool(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.getBool(key);
  }

  /// Store a list of strings with the given key
  /// Useful for storing arrays of data like recent searches, favorites, etc.
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.setStringList(key, value);
  }

  /// Retrieve a list of strings by key
  /// Returns null if key doesn't exist
  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.getStringList(key);
  }

  /// Store a complex object as JSON string
  /// Converts Map<String, dynamic> to JSON for storage
  /// Useful for storing structured data like user preferences, app state, etc.
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  /// Retrieve a complex object by key
  /// Decodes JSON string back to Map<String, dynamic>
  /// Throws exception if stored value is not a valid JSON object
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    final jsonString = _prefs!.getString(key);
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

  /// Remove a specific key-value pair
  /// Useful for cleaning up individual settings
  static Future<void> remove(String key) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.remove(key);
  }

  /// Clear all stored preferences
  /// Use with caution - this removes all app data
  static Future<void> clear() async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    await _prefs!.clear();
  }

  /// Check if a key exists in storage
  /// Returns false if key doesn't exist or SharedPreferences is not initialized
  static bool containsKey(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.containsKey(key);
  }

  /// Get all stored keys
  /// Useful for debugging or data export functionality
  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call PreferencesService.init() first.');
    }
    return _prefs!.getKeys();
  }
}
