import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../exception/app_exception.dart';

/// Provides database operations for the app using SQLite
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  /// Gets singleton database instance, initializing if needed
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database with schema and constraints
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path,
        version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  /// Creates database tables and schema on first creation
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Handles database schema upgrades between versions
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {}

  /// Creates a new user record in the database
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;

    final now = DateTime.now();
    int id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Gets a user by their ID
  static Future<User?> getUser(int id) async {
    final db = await database;

    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return User.fromMap(results.first);
  }

  /// Gets all users ordered by creation date
  static Future<List<User>> getAllUsers() async {
    final db = await database;

    final List<Map<String, dynamic>> results =
        await db.query('users', orderBy: 'created_at ASC');

    return results.map((map) => User.fromMap(map)).toList();
  }

  /// Updates an existing user's information
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;

    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw UserNotFoundException();
    }

    return User.fromMap(result.first);
  }

  /// Deletes a user by their ID
  static Future<void> deleteUser(int id) async {
    final db = await database;

    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets the total count of users in the database
  static Future<int> getUserCount() async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*)
      FROM users
      ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Searches users by name or email
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT * 
      FROM users 
      WHERE name LIKE ? OR email LIKE ?
      ''', ['%$query%', '%$query%']);

    return result.map((map) => User.fromMap(map)).toList();
  }

  /// Closes the database connection
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clears all data from the database
  static Future<void> clearAllData() async {
    final db = await database;

    await db.delete('posts');
    await db.delete('users');
  }

  /// Gets the full path to the database file
  static Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, _dbName);
  }
}
