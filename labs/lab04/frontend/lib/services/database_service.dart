import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String fullPath = join(dbPath, _dbName);
    return await openDatabase(
      fullPath,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT, published INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE)',
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // may be in future
  }

  static Future<User> createUser(CreateUserRequest request) async {
    final dbInstance = await database;
    String timestamp = DateTime.now().toIso8601String();
    final newId = await dbInstance.rawInsert(
      'INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?)',
      [request.name, request.email, timestamp, timestamp],
    );
    return User(
      id: newId,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(timestamp),
      updatedAt: DateTime.parse(timestamp),
    );
  }

  static Future<User?> getUser(int id) async {
    final dbInstance = await database;
    final results = await dbInstance.rawQuery(
      'SELECT * FROM users WHERE id = ? LIMIT 1',
      [id],
    );
    if (results.isEmpty) return null;
    var row = results.first;
    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  static Future<List<User>> getAllUsers() async {
    final dbInstance = await database;
    final records = await dbInstance.rawQuery('SELECT * FROM users ORDER BY created_at');
    return records.map((record) => User(
      id: record['id'] as int,
      name: record['name'] as String,
      email: record['email'] as String,
      createdAt: DateTime.parse(record['created_at'] as String),
      updatedAt: DateTime.parse(record['updated_at'] as String),
    )).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final dbInstance = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await dbInstance.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    final user = await getUser(id);
    if (user == null) throw Exception('Failed to find user after update');
    return user;
  }

  static Future<void> deleteUser(int id) async {
    final dbInstance = await database;
    await dbInstance.rawDelete('DELETE FROM users WHERE id = ?', [id]);
  }

  static Future<int> getUserCount() async {
    final dbInstance = await database;
    final queryResult = await dbInstance.rawQuery('SELECT COUNT(*) as total FROM users');
    return queryResult.first['total'] as int? ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final dbInstance = await database;
    final searchPattern = '%$query%';
    final results = await dbInstance.rawQuery(
      'SELECT * FROM users WHERE name LIKE ? OR email LIKE ?',
      [searchPattern, searchPattern],
    );
    return results.map((row) => User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final dbInstance = await database;
    await dbInstance.rawDelete('DELETE FROM posts');
    await dbInstance.rawDelete('DELETE FROM users');
  }

  static Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, _dbName);
  }
}