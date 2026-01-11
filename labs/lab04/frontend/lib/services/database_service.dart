import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Database getter: return existing or initialize
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Handle database schema upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migrations here if schema changes in future versions
  }

  // Create a user
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert(
      'users',
      {
        'name': request.name,
        'email': request.email,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  // Get user by id
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User.fromMap(map);
    }
    return null;
  }

  // Get all users ordered by created_at
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Update user fields, update updated_at timestamp
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );

    return (await getUser(id))!;
  }

  // Delete user by id, cascading deletes on posts (because of FK)
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Count users
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search users by name or email using LIKE operator
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final q = '%$query%';

    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [q, q],
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Close database connection
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data from tables, reset autoincrement counters
  static Future<void> clearAllData() async {
    final db = await database;
    // Use transaction for safety
    await db.transaction((txn) async {
      await txn.delete('posts');
      await txn.delete('users');

      // Reset autoincrement for SQLite
      await txn.execute('DELETE FROM sqlite_sequence WHERE name="users"');
      await txn.execute('DELETE FROM sqlite_sequence WHERE name="posts"');
    });
  }

  // Get full path to the database file
  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }
}
