import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.setInt(key, value);
  }


  static int? getInt(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> remove(String key) async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    await _prefs!.clear();
  }

  static bool containsKey(String key) {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.containsKey(key);
  }

  static Set<String> getAllKeys() {
    assert(_prefs != null, 'PreferencesService not initialized. Call init() first.');
    return _prefs!.getKeys();
  }
}
