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
    // Use the null-aware operator to check if _database exists
    _database ??= await _initDatabase();
    return _database!;
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // TODO: Initialize the SQLite database
    // - Get the databases path
    // - Join with database name
    // - Open database with version and callbacks
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // TODO: Create tables when database is first created
    // Create users table with: id, name, email, created_at, updated_at
    await db.execute(
      "CREATE TABLE users ("
      " id INTEGER PRIMARY KEY AUTOINCREMENT,"
      " name TEXT NOT NULL,"
      " email TEXT NOT NULL,"
      " created_at TEXT NOT NULL,"
      " updated_at TEXT NOT NULL)"
    );
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // TODO: Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now();
    final id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
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
    final db = await database;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final result =
        await db.query('users', orderBy: 'created_at DESC');
    return result.map((e) => User.fromMap(e)).toList();
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
    return (await getUser(id))!;
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users'));
    return result ?? 0;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((e) => User.fromMap(e)).toList();
  }

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
    await db.delete('users');
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}