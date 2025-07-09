import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  /// Returns existing database instance or initializes a new one.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Opens the database, setting up onCreate and onUpgrade callbacks.
  static Future<Database> _initDatabase() async {
    final path = await getDatabasePath();
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the required tables on first open.
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Handles schema upgrades when you bump [_version].
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // implement migration logic here if needed
  }

  /// Inserts a new user and returns the created [User].
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

  /// Fetches a user by [id], or returns null if not found.
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final m = maps.first;
    return User(
      id: m['id'] as int,
      name: m['name'] as String,
      email: m['email'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }

  /// Returns all users ordered by creation time.
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at',
    );
    return maps.map((m) => User(
      id: m['id'] as int,
      name: m['name'] as String,
      email: m['email'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    )).toList();
  }

  /// Updates a user by [id] with the given [updates] map and returns the updated [User].
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    // ensure updated_at is refreshed
    updates['updated_at'] = DateTime.now().toIso8601String();
    // convert any DateTime values to ISO strings
    final data = updates.map((k, v) => MapEntry(
      k,
      v is DateTime ? v.toIso8601String() : v,
    ));
    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    final user = await getUser(id);
    if (user == null) throw Exception('User not found');
    return user;
  }

  /// Deletes a user by [id].
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns the total number of users.
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Searches users by name or email matching [query].
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final pattern = '%$query%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
    );
    return maps.map((m) => User(
      id: m['id'] as int,
      name: m['name'] as String,
      email: m['email'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    )).toList();
  }

  /// Closes the database connection.
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Deletes all data (for testing) and resets auto-increment counters.
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
    await db.execute('DELETE FROM sqlite_sequence WHERE name = "users"');
    await db.execute('DELETE FROM sqlite_sequence WHERE name = "posts"');
  }

  /// Returns the full local filesystem path to the database file.
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
