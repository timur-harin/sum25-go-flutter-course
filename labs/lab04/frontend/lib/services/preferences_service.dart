import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Initializes SharedPreferences and stores the instance in _prefs variable
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Sets a string value in SharedPreferences
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  // Gets a string value from SharedPreferences, returns null if key doesn't exist
  static String? getString(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.getString(key);
  }

  // Sets an int value in SharedPreferences
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(key, value);
  }

  // Gets an int value from SharedPreferences
  static int? getInt(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.getInt(key);
  }

  // Sets a bool value in SharedPreferences
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(key, value);
  }

  // Gets a bool value from SharedPreferences
  static bool? getBool(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.getBool(key);
  }

  // Sets a string list in SharedPreferences
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) await init();
    await _prefs!.setStringList(key, value);
  }

  // Gets a string list from SharedPreferences
  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.getStringList(key);
  }

  // Sets an object (as JSON string) in SharedPreferences
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) await init();
    String jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // Gets an object from SharedPreferences and parses it back to Map
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    String? jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Removes a key from SharedPreferences
  static Future<void> remove(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  // Clears all data from SharedPreferences
  static Future<void> clear() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  // Checks if a key exists in SharedPreferences
  static bool containsKey(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.containsKey(key);
  }

  // Gets all keys from SharedPreferences
  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!.getKeys();
  }
}
