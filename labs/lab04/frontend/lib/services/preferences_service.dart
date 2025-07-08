import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  static SharedPreferences? _prefs;
  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;
    _prefs = await SharedPreferences.getInstance();
    _initialised = true;
  }

  static SharedPreferences _instance() {
    if (_prefs == null) {
      throw StateError('PreferencesService.init() has not been called yet');
    }
    return _prefs!;
  }

  static Future<void> setString(String key, String value) async =>
      _instance().setString(key, value);
  static String? getString(String key) => _instance().getString(key);

  static Future<void> setInt(String key, int value) async =>
      _instance().setInt(key, value);
  static int? getInt(String key) => _instance().getInt(key);

  static Future<void> setBool(String key, bool value) async =>
      _instance().setBool(key, value);
  static bool? getBool(String key) => _instance().getBool(key);

  static Future<void> setStringList(String key, List<String> value) async =>
      _instance().setStringList(key, value);
  static List<String>? getStringList(String key) =>
      _instance().getStringList(key);

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _instance().setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    final raw = _instance().getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> remove(String key) async => _instance().remove(key);
  static Future<void> clear() async => _instance().clear();

  static bool containsKey(String key) => _instance().containsKey(key);
  static Set<String> getAllKeys() => _instance().getKeys();
}