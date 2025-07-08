import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _prefs;

  // TODO: Implement init method
  static Future<void> init() async {
    // TODO: Initialize SharedPreferences
    // Store the instance in _prefs variable
    throw UnimplementedError('TODO: implement init method');
  }

  // TODO: Implement setString method
  static Future<void> setString(String key, String value) async {
    // TODO: Set string value in SharedPreferences
    // Make sure _prefs is not null
    throw UnimplementedError('TODO: implement setString method');
  }

  // TODO: Implement getString method
  static String? getString(String key) {
    // TODO: Get string value from SharedPreferences
    // Return null if key doesn't exist
    throw UnimplementedError('TODO: implement getString method');
  }

  // TODO: Implement setInt method
  static Future<void> setInt(String key, int value) async {
    // TODO: Set int value in SharedPreferences
    throw UnimplementedError('TODO: implement setInt method');
  }

  // TODO: Implement getInt method
  static int? getInt(String key) {
    // TODO: Get int value from SharedPreferences
    throw UnimplementedError('TODO: implement getInt method');
  }

  // TODO: Implement setBool method
  static Future<void> setBool(String key, bool value) async {
    // TODO: Set bool value in SharedPreferences
    throw UnimplementedError('TODO: implement setBool method');
  }

  // TODO: Implement getBool method
  static bool? getBool(String key) {
    // TODO: Get bool value from SharedPreferences
    throw UnimplementedError('TODO: implement getBool method');
  }

  // TODO: Implement setStringList method
  static Future<void> setStringList(String key, List<String> value) async {
    // TODO: Set string list in SharedPreferences
    throw UnimplementedError('TODO: implement setStringList method');
  }

  // TODO: Implement getStringList method
  static List<String>? getStringList(String key) {
    // TODO: Get string list from SharedPreferences
    throw UnimplementedError('TODO: implement getStringList method');
  }

  // TODO: Implement setObject method
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    // TODO: Set object (as JSON string) in SharedPreferences
    // Convert object to JSON string first
    throw UnimplementedError('TODO: implement setObject method');
  }

  // TODO: Implement getObject method
  static Map<String, dynamic>? getObject(String key) {
    // TODO: Get object from SharedPreferences
    // Parse JSON string back to Map
    throw UnimplementedError('TODO: implement getObject method');
  }

  // TODO: Implement remove method
  static Future<void> remove(String key) async {
    // TODO: Remove key from SharedPreferences
    throw UnimplementedError('TODO: implement remove method');
  }

  // TODO: Implement clear method
  static Future<void> clear() async {
    // TODO: Clear all data from SharedPreferences
    throw UnimplementedError('TODO: implement clear method');
  }

  // TODO: Implement containsKey method
  static bool containsKey(String key) {
    // TODO: Check if key exists in SharedPreferences
    throw UnimplementedError('TODO: implement containsKey method');
  }

  // TODO: Implement getAllKeys method
  static Set<String> getAllKeys() {
    // TODO: Get all keys from SharedPreferences
    throw UnimplementedError('TODO: implement getAllKeys method');
  }
}
