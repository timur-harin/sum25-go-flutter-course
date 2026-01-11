import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// User model for profile data.
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}

/// AuthService handles login, logout, token storage, and profile API calls.
class AuthService {
  static const _baseUrl = 'http://localhost:8080';
  final _client = http.Client();
  final _storage = const FlutterSecureStorage();

  /// Attempt login; returns true on success and stores JWT securely.
  Future<bool> login(String email, String password) async {
    final resp = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt', value: token);
        return true;
      }
    }
    return false;
  }

  /// Clear saved JWT.
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  /// Retrieve saved JWT.
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt');
  }

  /// Fetch profile data with authorization.
  Future<User> fetchProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');
    final resp = await _client.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer \$token'},
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to load profile: \${resp.statusCode}');
  }

  /// Update profile data.
  Future<User> updateProfile(String name, String email) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');
    final resp = await _client.put(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer \$token'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to update profile: \${resp.statusCode}');
  }
}
