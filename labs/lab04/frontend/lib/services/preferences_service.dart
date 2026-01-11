import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set string value in SharedPreferences
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setString(key, value);
  }

  // Get string value from SharedPreferences
  static String? getString(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getString(key);
  }

  // Set int value in SharedPreferences
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setInt(key, value);
  }

  // Get int value from SharedPreferences
  static int? getInt(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getInt(key);
  }

  // Set bool value in SharedPreferences
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setBool(key, value);
  }

  // Get bool value from SharedPreferences
  static bool? getBool(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getBool(key);
  }

  // Set string list in SharedPreferences
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setStringList(key, value);
  }

  // Get string list from SharedPreferences
  static List<String>? getStringList(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getStringList(key);
  }

  // Set object (as JSON string) in SharedPreferences
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // Get object from SharedPreferences
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Remove key from SharedPreferences
  static Future<void> remove(String key) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.remove(key);
  }

  // Clear all data from SharedPreferences
  static Future<void> clear() async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.clear();
  }

  // Check if key exists in SharedPreferences
  static bool containsKey(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.containsKey(key);
  }

  // Get all keys from SharedPreferences
  static Set<String> getAllKeys() {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getKeys();
  }
}
