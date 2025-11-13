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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(path, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
        published TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {

  }

  // User CRUD operations

  static Future<User> createUser(CreateUserRequest request) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('users', {'name': request.name, 'email': request.email, 'created_at': now, 'updated_at': now});

    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  static Future<User?> getUser(int id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> users = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (users.isEmpty) {
      return null;
    } else {
      final data = users.first;
      return User(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }
  }

  static Future<List<User>> getAllUsers() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((item) {return User(
      id: item['id'] as int,
      name: item['name'] as String,
      email: item['email'] as String,
      createdAt: DateTime.parse(item['created_at'] as String),
      updatedAt: DateTime.parse(item['updated_at'] as String),
    );}).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await DatabaseService.database;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    return await getUser(id) ?? (throw Exception('User not found after update'));
  }

  static Future<void> deleteUser(int id) async {
    final db = await DatabaseService.database;
    await db.delete('posts', where: "user_id = ?", whereArgs: [id]);
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getUserCount() async {
    final db = await DatabaseService.database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return result ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((data) {
      return User(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }).toList();
  }

  // Database utility methods

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    throw UnimplementedError('TODO: implement closeDatabase method');
  }

  static Future<void> clearAllData() async {
    final db = await DatabaseService.database;
    await db.delete('users');
    await db.delete('posts');
  }

  static Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, _dbName);
  }
}
