import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables when database is first created
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Handle database schema upgrades
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add migration logic here if needed
    }
  }

  // User CRUD operations

  // Create a new user
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now,
      'updated_at': now,
    });

    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  // Get user by ID
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'] as int,
        name: maps[0]['name'] as String,
        email: maps[0]['email'] as String,
        createdAt: DateTime.parse(maps[0]['created_at'] as String),
        updatedAt: DateTime.parse(maps[0]['updated_at'] as String),
      );
    }
    return null;
  }

  // Get all users
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at DESC');

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        email: maps[i]['email'] as String,
        createdAt: DateTime.parse(maps[i]['created_at'] as String),
        updatedAt: DateTime.parse(maps[i]['updated_at'] as String),
      );
    });
  }

  // Update user
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    updates['updated_at'] = now;
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );

    final updatedUser = await getUser(id);
    return updatedUser!;
  }

  // Delete user
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get user count
  static Future<int> getUserCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    ) ?? 0;
  }

  // Search users
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        email: maps[i]['email'] as String,
        createdAt: DateTime.parse(maps[i]['created_at'] as String),
        updatedAt: DateTime.parse(maps[i]['updated_at'] as String),
      );
    });
  }

  // Database utility methods

  // Close database connection
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  // Get database path
  static Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), _dbName);
  }
}