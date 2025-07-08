import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    _prefs?.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final json = jsonEncode(value);
    _prefs?.setString(key, json);
  }

  static Map<String, dynamic>? getObject(String key) {
    final json = _prefs?.getString(key);
    return json != null ? jsonDecode(json) : null;
  }

  static Future<void> remove(String key) async {
    _prefs?.remove(key);
  }

  static Future<void> clear() async {
    _prefs?.clear();
  }

  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
