import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // Инициализация SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Сохранить строку
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setString(key, value);
  }

  // Получить строку
  static String? getString(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.getString(key);
  }

  // Сохранить int
  static Future<void> setInt(String key, int value) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setInt(key, value);
  }

  // Получить int
  static int? getInt(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.getInt(key);
  }

  // Сохранить bool
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setBool(key, value);
  }

  // Получить bool
  static bool? getBool(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.getBool(key);
  }

  // Сохранить список строк
  static Future<void> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setStringList(key, value);
  }

  // Получить список строк
  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.getStringList(key);
  }

  // Сохранить объект (как JSON строку)
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    if (_prefs == null) {
      await init();
    }
    String jsonString = jsonEncode(value);
    await _prefs!.setString(key, jsonString);
  }

  // Получить объект (Map) из JSON строки
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    String? jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Удалить ключ
  static Future<void> remove(String key) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.remove(key);
  }

  // Очистить все данные
  static Future<void> clear() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.clear();
  }

  // Проверить наличие ключа
  static bool containsKey(String key) {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.containsKey(key);
  }

  // Получить все ключи
  static Set<String> getAllKeys() {
    if (_prefs == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _prefs!.getKeys();
  }
}
