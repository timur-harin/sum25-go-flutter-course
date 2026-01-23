import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // init method implementation
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // setStrings method implementation
  static Future<void> setString(String key, String value) async {
    await initIfNeeded();
    await _prefs!.setString(key, value);
  }

  // getString method implementation
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // setInt method implementation
  static Future<void> setInt(String key, int value) async {
    await initIfNeeded();
    await _prefs!.setInt(key, value);
  }

  // getInt method implementation
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // setBool method implementation
  static Future<void> setBool(String key, bool value) async {
    await initIfNeeded();
    await _prefs!.setBool(key, value);
  }

  // getBool method implementation
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // setStringList method implementation
  static Future<void> setStringList(String key, List<String> value) async {
    await initIfNeeded();
    await _prefs!.setStringList(key, value);
  }

  // getStringList method implementation
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // setObject method implementation
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await initIfNeeded();
    final jsonString = json.encode(value);
    await _prefs!.setString(key, jsonString);
  }

  // getObject method implementation
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // remove method implementation
  static Future<void> remove(String key) async {
    await initIfNeeded();
    await _prefs!.remove(key);
  }

  // clear method implementation
  static Future<void> clear() async {
    await initIfNeeded();
    await _prefs!.clear();
  }

  // containsKey method implementation
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // getAllKeys method implementation
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // Additional helper method for initialization ensuring
  static Future<void> initIfNeeded() async {
    if (_prefs == null) {
      await init();
    }
  }
}
