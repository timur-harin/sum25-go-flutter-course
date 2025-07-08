import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // TODO: Implement init method
  static Future<void> init() async {
    // TODO: Initialize SharedPreferences
    // Store the instance in _prefs variable
    _prefs = await SharedPreferences.getInstance();
  }

  // TODO: Implement setString method
  static Future<void> setString(String key, String value) async {
    // TODO: Set string value in SharedPreferences
    // Make sure _prefs is not null
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setString(key, value);
  }

  // TODO: Implement getString method
  static String? getString(String key) {
    // TODO: Get string value from SharedPreferences
    // Return null if key doesn't exist
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getString(key);
  }

  // TODO: Implement setInt method
  static Future<void> setInt(String key, int value) async {
    // TODO: Set int value in SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setInt(key, value);
  }

  // TODO: Implement getInt method
  static int? getInt(String key) {
    // TODO: Get int value from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getInt(key);
  }

  // TODO: Implement setBool method
  static Future<void> setBool(String key, bool value) async {
    // TODO: Set bool value in SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setBool(key, value);
  }

  // TODO: Implement getBool method
  static bool? getBool(String key) {
    // TODO: Get bool value from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getBool(key);
  }

  // TODO: Implement setStringList method
  static Future<void> setStringList(String key, List<String> value) async {
    // TODO: Set string list in SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setStringList(key, value);
  }

  // TODO: Implement getStringList method
  static List<String>? getStringList(String key) {
    // TODO: Get string list from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getStringList(key);
  }

  // TODO: Implement setObject method
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    // TODO: Set object (as JSON string) in SharedPreferences
    // Convert object to JSON string first
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // TODO: Implement getObject method
  static Map<String, dynamic>? getObject(String key) {
    // TODO: Get object from SharedPreferences
    // Parse JSON string back to Map
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // TODO: Implement remove method
  static Future<void> remove(String key) async {
    // TODO: Remove key from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.remove(key);
  }

  // TODO: Implement clear method
  static Future<void> clear() async {
    // TODO: Clear all data from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.clear();
  }

  // TODO: Implement containsKey method
  static bool containsKey(String key) {
    // TODO: Check if key exists in SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.containsKey(key);
  }

  // TODO: Implement getAllKeys method
  static Set<String> getAllKeys() {
    // TODO: Get all keys from SharedPreferences
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getKeys();
  }
}
