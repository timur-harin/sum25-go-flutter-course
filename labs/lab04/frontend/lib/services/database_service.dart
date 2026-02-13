import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  /// Getter to open (and cache) the database instance.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), _dbName);
    _database = await openDatabase(
      dbPath,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            published INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');
      },
    );
    return _database!;
  }

  /// Inserts a new user record based on [CreateUserRequest] and returns created [User].
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final nowIso = DateTime.now().toIso8601String();

    final insertedId = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    return User(
      id: insertedId,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(nowIso),
      updatedAt: DateTime.parse(nowIso),
    );
  }

  /// Retrieves a user by [id]. Returns null if not found.
  static Future<User?> getUser(int id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return _fromMap(results.first);
  }

  /// Retrieves all users sorted by creation date ascending.
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final results = await db.query('users', orderBy: 'created_at ASC');
    return results.map(_fromMap).toList();
  }

  /// Updates user with [id] using provided fields in [updates].
  /// Automatically updates `updated_at` timestamp.
  /// Returns the updated user.
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final nowIso = DateTime.now().toIso8601String();
    updates['updated_at'] = nowIso;

    await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return _fromMap(results.first);
  }

  /// Deletes user by [id].
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns total number of users in the database.
  static Future<int> getUserCount() async {
    final db = await database;
    final countResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(countResult) ?? 0;
  }

  /// Searches users by name or email matching [query].
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map(_fromMap).toList();
  }

  /// Deletes all data in users and posts tables.
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  /// Closes the database connection and resets the cache.
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Returns the full file system path to the database file.
  static Future<String> getDatabasePath() async {
    final basePath = await getDatabasesPath();
    return join(basePath, _dbName);
  }

  /// Converts a database map to a User instance.
  static User _fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
