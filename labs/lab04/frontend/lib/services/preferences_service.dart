import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing simple key-value storage using SharedPreferences
/// Perfect for app settings, user preferences, and simple data caching
class PreferencesService {
  static SharedPreferences? _prefs;

  /// Initializes the SharedPreferences instance
  /// Call this once before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Stores a string value with the given key
  /// Automatically initializes preferences if not already done
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  /// Retrieves a string value for the given key
  /// Returns null if key doesn't exist
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Stores an integer value with the given key
  /// Automatically initializes preferences if not already done
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(key, value);
  }

  /// Retrieves an integer value for the given key
  /// Returns null if key doesn't exist
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Stores a boolean value with the given key
  /// Automatically initializes preferences if not already done
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(key, value);
  }

  /// Retrieves a boolean value for the given key
  /// Returns null if key doesn't exist
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Stores a list of strings with the given key
  /// Automatically initializes preferences if not already done
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) await init();
    await _prefs!.setStringList(key, value);
  }

  /// Retrieves a list of strings for the given key
  /// Returns null if key doesn't exist
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Stores a complex object as JSON string with the given key
  /// The object must be serializable to JSON
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) await init();
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  /// Retrieves a complex object from JSON string for the given key
  /// Returns null if key doesn't exist or JSON parsing fails
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Removes a specific key and its value from preferences
  /// Automatically initializes preferences if not already done
  static Future<void> remove(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  /// Clears all data from preferences
  /// Use with caution as this removes all stored preferences
  static Future<void> clear() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  /// Checks if a key exists in preferences
  /// Returns false if preferences are not initialized
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Returns all keys currently stored in preferences
  /// Returns empty set if preferences are not initialized
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}
