import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../exception/app_exception.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  /// Initializes the SharedPreferences instance that will be used throughout the app
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves a string value to SharedPreferences with the specified key
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setString(key, value);
  }

  /// Retrieves a string value from SharedPreferences using the specified key
  static String? getString(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getString(key);
  }

  /// Saves an integer value to SharedPreferences with the specified key
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setInt(key, value);
  }

  /// Retrieves an integer value from SharedPreferences using the specified key
  static int? getInt(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getInt(key);
  }

  /// Saves a boolean value to SharedPreferences with the specified key
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setBool(key, value);
  }

  /// Retrieves a boolean value from SharedPreferences using the specified key
  static bool? getBool(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getBool(key);
  }

  /// Saves a list of strings to SharedPreferences with the specified key
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setStringList(key, value);
  }

  /// Retrieves a list of strings from SharedPreferences using the specified key
  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getStringList(key);
  }

  /// Saves an object (as JSON) to SharedPreferences with the specified key
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  /// Retrieves and deserializes an object from SharedPreferences using the specified key
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw PreferencesParseException(key);
    }
  }

  /// Removes the value associated with the specified key from SharedPreferences
  static Future<void> remove(String key) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.remove(key);
  }

  /// Clears all values stored in SharedPreferences
  static Future<void> clear() async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.clear();
  }

  /// Checks if SharedPreferences contains a value for the specified key
  static bool containsKey(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.containsKey(key);
  }

  /// Retrieves all keys currently stored in SharedPreferences
  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getKeys();
  }
}
