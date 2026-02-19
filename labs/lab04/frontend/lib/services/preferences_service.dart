import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    if (_prefs != null) {
      await _prefs!.setString(key, value);
    }
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    if (_prefs != null) {
      await _prefs!.setInt(key, value);
    }
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    if (_prefs != null) {
      await _prefs!.setBool(key, value);
    }
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs != null) {
      await _prefs!.setStringList(key, value);
    }
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs != null) {
      String jsonString = json.encode(value);
      await _prefs!.setString(key, jsonString  // Get bool value from SharedPreferences
);
    }
  }

  static Map<String, dynamic>? getObject(String key) {
    String? jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return null;
  }

  static Future<void> remove(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }

  static Future<void> clear() async {
    if (_prefs != null) {
      await _prefs!.clear();
    }
  }

  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
