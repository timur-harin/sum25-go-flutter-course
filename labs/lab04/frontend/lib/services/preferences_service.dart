import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../exception/app_exception.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getStringList(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    final jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw PreferencesParseException("$key");
    }
  }

  static Future<void> remove(String key) async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    await _prefs!.clear();
  }

  static bool containsKey(String key) {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.containsKey(key);
  }

  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw UninitializedPreferencesException();
    }

    return _prefs!.getKeys();
  }
}
class UninitializedPreferencesException extends AppException {
  UninitializedPreferencesException() : super("Preferences service not initialized");
}

class PreferencesParseException extends AppException {
  PreferencesParseException(String message) :
    super(message, "Failed to parse JSON object for key: ");
}