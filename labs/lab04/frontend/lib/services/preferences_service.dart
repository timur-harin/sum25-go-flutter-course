import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a string value for given key
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  // Retrieve a string value by key, returns null if not found
  static String? getString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  // Save an integer value for given key
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(key, value);
  }

  // Retrieve an integer value by key, returns null if not found
  static int? getInt(String key) {
    if (_prefs == null) return null;
    return _prefs!.getInt(key);
  }

  // Save a boolean value for given key
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(key, value);
  }

  // Retrieve a boolean value by key, returns null if not found
  static bool? getBool(String key) {
    if (_prefs == null) return null;
    return _prefs!.getBool(key);
  }

  // Save a list of strings for given key
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) await init();
    await _prefs!.setStringList(key, value);
  }

  // Retrieve a list of strings by key, returns null if not found
  static List<String>? getStringList(String key) {
    if (_prefs == null) return null;
    return _prefs!.getStringList(key);
  }

  // Save a Map<String, dynamic> object as JSON string
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) await init();
    String jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // Retrieve a Map<String, dynamic> object from JSON string
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) return null;
    String? jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Remove a specific key and its value
  static Future<void> remove(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  // Clear all stored keys and values
  static Future<void> clear() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  // Check if a key exists in SharedPreferences
  static bool containsKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }

  // Get all keys currently stored
  static Set<String> getAllKeys() {
    if (_prefs == null) return {};
    return _prefs!.getKeys();
  }
}
