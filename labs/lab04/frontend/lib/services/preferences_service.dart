import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // TODO: Implement init method
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // TODO: Implement setString method
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setString(key, value);
  }

  // TODO: Implement getString method
  static String? getString(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getString(key);
  }

  // TODO: Implement setInt method
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setInt(key, value);
  }

  // TODO: Implement getInt method
  static int? getInt(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getInt(key);
  }

  // TODO: Implement setBool method
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setBool(key, value);
  }

  // TODO: Implement getBool method
  static bool? getBool(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getBool(key);
  }

  // TODO: Implement setStringList method
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.setStringList(key, value);
  }

  // TODO: Implement getStringList method
  static List<String>? getStringList(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getStringList(key);
  }

  // TODO: Implement setObject method
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // TODO: Implement getObject method
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // TODO: Implement remove method
  static Future<void> remove(String key) async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.remove(key);
  }

  // TODO: Implement clear method
  static Future<void> clear() async {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    await _prefs!.clear();
  }

  // TODO: Implement containsKey method
  static bool containsKey(String key) {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.containsKey(key);
  }

  // TODO: Implement getAllKeys method
  static Set<String> getAllKeys() {
    if (_prefs == null) throw Exception('PreferencesService not initialized');
    return _prefs!.getKeys();
  }
}
