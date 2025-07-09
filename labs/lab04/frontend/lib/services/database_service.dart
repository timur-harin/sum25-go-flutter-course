import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import 'dart:async';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = await getDatabasePath();
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
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
      )
    ''');

    await db.execute('CREATE INDEX idx_posts_user_id ON posts(user_id)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN avatar_url TEXT');
    }
  }

  // User CRUD operations

  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final timeNow = DateTime.now().toIso8601String();

    final id = await db.insert(
      'users',
      {
        'name' :  request.name,
        'email' : request.email,
        'created_at' : timeNow,
        'updated_at' : timeNow
      }
    );

    final userMap =  await db.query('users', where : 'id = ?', whereArgs : [id]);
    return User.fromJson(userMap.first);
  }

  static Future<User?> getUser(int id) async {
    final db = await database;

    final userMap = await db.query('users', where : 'id = ?', whereArgs : [id]);
    return userMap.isEmpty ? null : User.fromJson(userMap.first);
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;

    final users = await db.query('users', orderBy: 'created_at');
    return users.map((user) => User.fromJson(user)).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    if (updates.isEmpty) {
      throw ArgumentError("No fields to update"); 
    }

    updates['updated_at'] = DateTime.now().toIso8601String();

    final count = await db.update('users', updates, where : 'id = ?', whereArgs : [id]);
    if (count == 0) {
      throw Exception("User not found");
    }

    final updatedUser = await getUser(id);
    return updatedUser!;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;

    final found =  await db.delete('users', where : 'id = ?', whereArgs : [id]);
    if (found == 0) {
      throw Exception("User not found");
    }
  }

  static Future<int> getUserCount() async {
    final allUsers = await getAllUsers();
    return allUsers.length;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final searchPattern = '%${query.trim()}%';

    final users = await db.query(
      'users',
      where : 'name LIKE ? OR email LIKE ?',
      whereArgs: [searchPattern, searchPattern],
      orderBy: 'created_at'
    );

    return users.map((user) => User.fromJson(user)).toList();
  }

  // Database utility methods

  static Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
   final db = await database;
   await db.transaction((txn) async {
      await txn.delete('posts');
      await txn.delete('users');
    });
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
