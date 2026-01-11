import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  static bool containsKey(String key) {
    if (_prefs?.containsKey(key) == true) return true;
    return false;
  }

  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}
