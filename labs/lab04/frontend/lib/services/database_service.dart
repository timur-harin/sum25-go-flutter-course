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
    final dbPath = await getDatabasePath();
    return await openDatabase(
      dbPath,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }

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
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // implement migration if needed in future
  }

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

  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    final data = maps.first;
    return User(
      id: data['id'] as int,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at');
    return maps.map((data) => User(
      id: data['id'] as int,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    )).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;

    // Ensure updated_at is set
    updates['updated_at'] = DateTime.now().toIso8601String();

    final count = await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) {
      throw Exception('User with id $id not found');
    }
    final updatedUser = await getUser(id);
    if (updatedUser == null) {
      throw Exception('User with id $id not found after update');
    }
    return updatedUser;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    final count = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) {
      throw Exception('User with id $id not found');
    }
  }

  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final likeQuery = '%$query%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [likeQuery, likeQuery],
      orderBy: 'name',
    );
    return maps.map((data) => User(
      id: data['id'] as int,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    )).toList();
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
    // Optional: vacuum to reset auto increment
    await db.execute('VACUUM');
  }
}
