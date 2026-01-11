import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // ───────────────────────────────────────────────────────────────────── init
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ───────────────────────────────────────────────────────────── helpers
  static Future<void> _ensure() async {
    if (_prefs == null) await init();
  }

  // ───────────────────────────────────────────────────────────── setters
  static Future<void> setString(String key, String value) async {
    await _ensure();
    await _prefs!.setString(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await _ensure();
    await _prefs!.setInt(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _ensure();
    await _prefs!.setBool(key, value);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _ensure();
    await _prefs!.setStringList(key, value);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _ensure();
    final jsonStr = json.encode(value);
    await _prefs!.setString(key, jsonStr);
  }

  // ───────────────────────────────────────────────────────────── getters
  static String? getString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  static int? getInt(String key) {
    if (_prefs == null) return null;
    return _prefs!.getInt(key);
  }

  static bool? getBool(String key) {
    if (_prefs == null) return null;
    return _prefs!.getBool(key);
  }

  static List<String>? getStringList(String key) {
    if (_prefs == null) return null;
    return _prefs!.getStringList(key);
  }

  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) return null;
    final jsonStr = _prefs!.getString(key);
    if (jsonStr == null) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ───────────────────────────────────────────────────────── remove/clear
  static Future<void> remove(String key) async {
    await _ensure();
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    await _ensure();
    await _prefs!.clear();
  }

  // ───────────────────────────────────────────────────────── meta
  static bool containsKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }

  static Set<String> getAllKeys() {
    if (_prefs == null) return <String>{};
    return _prefs!.getKeys();
  }
}
