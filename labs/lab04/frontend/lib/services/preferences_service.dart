import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance; must be called before usage.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves a string value under [key].
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Retrieves a string value for [key], or null if none.
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Saves an integer value under [key].
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Retrieves an integer value for [key], or null if none.
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Saves a boolean value under [key].
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Retrieves a boolean value for [key], or null if none.
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Saves a list of strings under [key].
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  /// Retrieves a list of strings for [key], or null if none.
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Saves a JSON-serializable object (map) under [key].
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonStr = jsonEncode(value);
    await _prefs?.setString(key, jsonStr);
  }

  /// Retrieves a JSON object (map) for [key], or null if none.
  static Map<String, dynamic>? getObject(String key) {
    final jsonStr = _prefs?.getString(key);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  /// Removes the value associated with [key].
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clears all stored keys and values.
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  /// Checks if a value exists for [key].
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Returns all keys currently stored.
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
