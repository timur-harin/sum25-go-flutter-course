// preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Integer operations
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Boolean operations
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // String list operations
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // Object operations (JSON serialization)
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    await setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Data management
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Key management
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
