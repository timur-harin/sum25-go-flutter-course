import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    final jsonString = _prefs!.getString(key);
    return jsonString != null ? json.decode(jsonString) : null;
  }

  static Future<void> remove(String key) async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    await _prefs!.clear();
  }

  static bool containsKey(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.containsKey(key);
  }

  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }

    return _prefs!.getKeys();
  }
}
