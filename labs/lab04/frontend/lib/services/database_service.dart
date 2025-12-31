// labs/lab04/frontend/lib/services/database_service.dart
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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // For now, we'll just recreate the database
    await db.execute('DROP TABLE IF EXISTS users');
    await _onCreate(db, newVersion);
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

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at');
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    final updatedUser = await getUser(id);
    return updatedUser!;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getUserCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    );
    return count ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}