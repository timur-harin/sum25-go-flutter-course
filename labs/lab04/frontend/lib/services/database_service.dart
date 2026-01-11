import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Returns existing database or initializes a new one if null
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initializes the SQLite database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Creates tables when database is first created
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL DEFAULT (DATETIME('now')),
        updated_at TEXT NOT NULL DEFAULT (DATETIME('now'))
      )
    ''');

    // Create posts table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (DATETIME('now')),
        updated_at TEXT NOT NULL DEFAULT (DATETIME('now')),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Handles database schema upgrades (empty for now)
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Add migration logic here if needed in the future
  }

  // User CRUD operations

  // Inserts a new user into the database and returns the created User
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final userMap = {
      'name': request.name,
      'email': request.email,
      'created_at': now,
      'updated_at': now,
    };
    final id = await db.insert('users', userMap);
    final user = await getUser(id);
    if (user == null) {
      throw Exception('Failed to create user');
    }
    return user;
  }

  // Retrieves a user by ID from the database
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Retrieves all users ordered by created_at
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // Updates a user with provided data and returns the updated User
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    final count = await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) {
      throw Exception('User not found');
    }
    final user = await getUser(id);
    if (user == null) {
      throw Exception('Failed to fetch updated user');
    }
    return user;
  }

  // Deletes a user by ID from the database
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Posts will be deleted automatically due to ON DELETE CASCADE
  }

  // Counts total number of users in the database
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Searches users by name or email using LIKE operator
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // Database utility methods

  // Closes the database connection and sets _database to null
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clears all data from all tables (for testing)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
    // Optionally, reset auto-increment counters
    await db.execute(
        'DELETE FROM sqlite_sequence WHERE name="users" OR name="posts"');
  }

  // Returns the full path to the database file
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
