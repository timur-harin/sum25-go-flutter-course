import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database?> get database async {
    // TODO: Return existing database or initialize new one
    // Use the null-aware operator to check if _database exists
    if(_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // TODO: Initialize the SQLite database
    // - Get the databases path
    // - Join with database name
    // - Open database with version and callbacks
    String dbDirPath;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      dbDirPath = docDir.path;
    } catch (_) {
      dbDirPath = Directory.systemTemp.path;
    }

    final path = join(dbDirPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // TODO: Create tables when database is first created
    // Create users table with: id, name, email, created_at, updated_at
    // Create posts table with: id, user_id, title, content, published, created_at, updated_at
    // Include proper PRIMARY KEY and FOREIGN KEY constraints
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX isx_posts_user_id ON posts(user_id)');
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
    if(oldVersion < 2){
      await db.execute('ALTER TABLE users ADD COLUMN avatar_url TEXT');
    }
  }

  // User CRUD operations

  // TODO: Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    // TODO: Insert user into database
    // - Get database instance
    // - Insert user data
    // - Return User object with generated ID and timestamps
    final db = await database;
    final now = DateTime.now();

    final id = await db!.insert(
      'users', {
        'name': request.name,
        'email': request.email,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
    );
  }

  // TODO: Implement getUser method
  static Future<User?> getUser(int id) async {
    // TODO: Get user by ID from database
    // - Query users table by ID
    // - Return User object or null if not found
    final db = await database;
    final res = await db!.query(
      'users',
      columns: ['id', 'name', 'email', 'created_at', 'updated_at'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) {
      final row = res.first;
      return User(
        id: row['id'] as int,
        name: row['name'] as String,
        email: row['email'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    }
    return null;
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    // TODO: Get all users from database
    // - Query all users ordered by created_at
    // - Convert query results to User objects
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('users');
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    // TODO: Update user in database
    // - Update user with provided data
    // - Update the updated_at timestamp
    // - Return updated User object
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await db!.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    return await getUser(id) as User;
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    // TODO: Delete user from database
    // - Delete user by ID
    // - Consider cascading deletes for related data
    final db = await database;
    await db!.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    // TODO: Count total number of users
    // - Query count from users table
    final db = await database;
    final res = await db!.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    // TODO: Search users by name or email
    // - Use LIKE operator for pattern matching
    // - Search in both name and email fields
    final db = await database;
    final pattern = '%$query%';
    final res = await db!.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
    );
    return res.map((row) => User.fromJson(row)).toList();
  }

  // Database utility methods

  // TODO: Implement closeDatabase method
  static Future<void> closeDatabase() async {
    // TODO: Close database connection
    // - Close the database if it exists
    // - Set _database to null
    var db = await database;
    await db!.close();
    _database = null;
  }

  // TODO: Implement clearAllData method
  static Future<void> clearAllData() async {
    // TODO: Clear all data from database (for testing)
    // - Delete all records from all tables
    // - Reset auto-increment counters if needed
    final db = await database;
    await db!.delete('posts');
    await db.delete('users');

    await db.execute("DELETE FROM sqlite_sequence WHERE name = 'users'");
    await db.execute("DELETE FROM sqlite_sequence WHERE name = 'posts'");
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    // TODO: Get the full path to the database file
    // - Return the complete path to the database file
    final db = await database;
    return (db! as dynamic).path as String;
  }
}
