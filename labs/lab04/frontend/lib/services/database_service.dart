import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

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
        published INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final userData = {
      ...request.toJson(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String()
    };
    int id = await db.insert('users', userData);
    final createdUser = await getUser(id);
    if (createdUser != null) {
      return createdUser;
    }
    throw Exception("Updated user does not exist");
  }

  static Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id]
    );
    return maps.isNotEmpty ? User.fromJson(maps.first) : null;
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users'
    );
    return List.generate(maps.length, (index) => User.fromJson(maps[index]));
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final finalUpdates = {
      ...updates,
      'updated_at': DateTime.now().toIso8601String()
    };
    final db = await database;
    await db.update(
      'users',
      finalUpdates,
      where: 'id = ?',
      whereArgs: [id]
    );
    
    final updatedUser = await getUser(id);
    if (updatedUser != null) {
      return updatedUser;
    }
    throw Exception("Updated user does not exist");
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  static Future<int> getUserCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM users');
    int count = Sqflite.firstIntValue(res) ?? 0;
    return count;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    String pattern = '%$query%';
    final users = await db.rawQuery(
      'SELECT * FROM users WHERE name LIKE ? OR email LIKE ?',
      [pattern, pattern]
    );
    return List.generate(users.length, (index) => User.fromJson(users[index]));
  }

  // Database utility methods

  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('posts');

    await db.rawDelete('DELETE FROM sqlite_sequence WHERE name = ?', ['users']);
    await db.rawDelete('DELETE FROM sqlite_sequence WHERE name = ?', ['posts']);
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return path;
  }
}
