import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // TODO: Implement init method
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // TODO: Implement setString method
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  // TODO: Implement getString method
  static String? getString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  // TODO: Implement setInt method
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  // TODO: Implement getInt method
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // TODO: Implement setBool method
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // TODO: Implement getBool method
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // TODO: Implement setStringList method
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  // TODO: Implement getStringList method
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // TODO: Implement setObject method
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  // TODO: Implement getObject method
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // TODO: Implement remove method
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // TODO: Implement clear method
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // TODO: Implement containsKey method
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // TODO: Implement getAllKeys method
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}
