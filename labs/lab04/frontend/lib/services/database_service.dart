import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database> get database async {
    // TODO: Return existing database or initialize new one
    if (_database != null) {
      return _database!;
    }
    if (_database == null) {
      _database = await _initDatabase();
      return _database!;
    }
    throw Exception('Database not initialized. Call init() first.');
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // Get the default databases location
    final dbPath = await getDatabasesPath();
    // Construct the full database path
    final path = join(dbPath, _dbName);

    // Open the database with version and callbacks
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // TODO: Implement _onCreate method
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
        content TEXT,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  // TODO: Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    // TODO: Insert user into database
    final db = await database;

    final now = DateTime.now();
    int id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // - Get database instance
    // - Insert user data
    // - Return User object with generated ID and timestamps
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

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    List<User> users = results.map((map) => User.fromMap(map)).toList();
    return users;
  }

  // TODO: Implement updateUser method
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

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      throw Exception('User not found');
    }
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    List<User> users = result.map((map) => User.fromMap(map)).toList();
    return users;
    // return result.map((map) => User.fromMap(map)).toList();
  }

  // Database utility methods

  // TODO: Implement closeDatabase method
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // TODO: Implement clearAllData method
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, _dbName);
  }
}
