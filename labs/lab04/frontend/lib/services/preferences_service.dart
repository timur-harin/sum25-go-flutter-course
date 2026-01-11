import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set string value
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // Get string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Set int value
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  // Get int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Set bool value
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // Get bool value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Set string list
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  // Get string list
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // Set object (as JSON string)
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    await _prefs?.setString(key, jsonString);
  }

  // Get object (from JSON string)
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;

    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Remove a key
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // Clear all keys
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // Get all keys
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
