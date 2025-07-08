import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  static Future setInt(String key, int value) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    if (_prefs == null) return null;
    return _prefs!.getInt(key);
  }

  static Future setBool(String key, bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    if (_prefs == null) return null;
    return _prefs!.getBool(key);
  }

  static Future setStringList(String key, List<String> value) async {
    if (_prefs == null) await init();
    await _prefs!.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    if (_prefs == null) return null;
    return _prefs!.getStringList(key);
  }

  static Future setObject(String key, Map value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, jsonEncode(value));
  }

  static Map? getObject(String key) {
    if (_prefs == null) return null;
    final str = _prefs!.getString(key);
    if (str == null) return null;
    return jsonDecode(str);
  }

  static Future remove(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  static Future clear() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  static bool containsKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }

  static Set<String> getAllKeys() {
    if (_prefs == null) return {};
    return _prefs!.getKeys();
  }
}
