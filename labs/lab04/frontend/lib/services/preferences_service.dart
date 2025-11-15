import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Implement init method
  static Future<void> init() async {
    // Initialize SharedPreferences
    // Store the instance in _prefs variable
    _prefs = await SharedPreferences.getInstance();
  }

  // Implement setString method
  static Future<void> setString(String key, String value) async {
    // Set string value in SharedPreferences
    // Make sure _prefs is not null
    await _prefs?.setString(key, value);
  }

  // Implement getString method
  static String? getString(String key) {
    // Get string value from SharedPreferences
    // Return null if key doesn't exist
    return _prefs?.getString(key);
  }

  // Implement setInt method
  static Future<void> setInt(String key, int value) async {
    // Set int value in SharedPreferences
    await _prefs?.setInt(key, value);
  }

  // Implement getInt method
  static int? getInt(String key) {
    // Get int value from SharedPreferences
    return _prefs?.getInt(key);
  }

  // Implement setBool method
  static Future<void> setBool(String key, bool value) async {
    // Set bool value in SharedPreferences
    _prefs?.setBool(key, value);
  }

  // Implement getBool method
  static bool? getBool(String key) {
    // Get bool value from SharedPreferences
    return _prefs?.getBool(key);
  }

  // Implement setStringList method
  static Future<void> setStringList(String key, List<String> value) async {
    // Set string list in SharedPreferences
    _prefs?.setStringList(key, value);
  }

  // Implement getStringList method
  static List<String>? getStringList(String key) {
    // Get string list from SharedPreferences
    return _prefs?.getStringList(key);
  }

  // Implement setObject method
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    // Set object (as JSON string) in SharedPreferences
    // Convert object to JSON string first
    await setString(key, jsonEncode(value));
  }

  // Implement getObject method
  static Map<String, dynamic>? getObject(String key) {
    // Get object from SharedPreferences
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Implement remove method
  static Future<void> remove(String key) async {
    // Remove key from SharedPreferences
    await _prefs?.remove(key);
  }

  // Implement clear method
  static Future<void> clear() async {
    // Clear all data from SharedPreferences
    await _prefs?.clear();
  }

  // Implement containsKey method
  static bool containsKey(String key) {
    // Check if key exists in SharedPreferences
    return _prefs?.containsKey(key) ?? false;
  }

  // Implement getAllKeys method
  static Set<String> getAllKeys() {
    // Get all keys from SharedPreferences
    return _prefs?.getKeys() ?? <String>{};
  }
}
