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
    await _checkInitialized();
    await _prefs!.setString(key, value);
  }

  // Get string value
  static String? getString(String key) {
    _checkInitializedSync();
    return _prefs!.getString(key);
  }

  // Set int value
  static Future<void> setInt(String key, int value) async {
    await _checkInitialized();
    await _prefs!.setInt(key, value);
  }

  // Get int value
  static int? getInt(String key) {
    _checkInitializedSync();
    return _prefs!.getInt(key);
  }

  // Set bool value
  static Future<void> setBool(String key, bool value) async {
    await _checkInitialized();
    await _prefs!.setBool(key, value);
  }

  // Get bool value
  static bool? getBool(String key) {
    _checkInitializedSync();
    return _prefs!.getBool(key);
  }

  // Set string list
  static Future<void> setStringList(String key, List<String> value) async {
    await _checkInitialized();
    await _prefs!.setStringList(key, value);
  }

  // Get string list
  static List<String>? getStringList(String key) {
    _checkInitializedSync();
    return _prefs!.getStringList(key);
  }

  // Set object as JSON string
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _checkInitialized();
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // Get object from JSON string
  static Map<String, dynamic>? getObject(String key) {
    _checkInitializedSync();
    final jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Remove key
  static Future<void> remove(String key) async {
    await _checkInitialized();
    await _prefs!.remove(key);
  }

  // Clear all data
  static Future<void> clear() async {
    await _checkInitialized();
    await _prefs!.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    _checkInitializedSync();
    return _prefs!.containsKey(key);
  }

  // Get all keys
  static Set<String> getAllKeys() {
    _checkInitializedSync();
    return _prefs!.getKeys();
  }

  // Private helper to check initialization (async)
  static Future<void> _checkInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  // Private helper to check initialization (sync)
  static void _checkInitializedSync() {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call PreferencesService.init() first.');
    }
  }
}