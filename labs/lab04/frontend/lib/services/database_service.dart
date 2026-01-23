import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Database getter implementation
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // _initDatabase method implementation
  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // _onCreate method implementation
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

  // _onUpgrade method implementation
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS users');
      await _onCreate(db, newVersion);
    }
  }

  // User CRUD operations

  // createUser method implementation
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();

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

  // getUser method implementation
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  // getAllUsers method implementation
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // updateUser method implementation
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();

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

  // deleteUser method implementation
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // getUserCount method implementation
  static Future<int> getUserCount() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT COUNT(*) FROM users');
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  // searchUsers method implementation
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // Database utility methods

  // closeDatabase method implementation
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // clearAllData method implementation
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
  }

  // getDatabasePath method implementation
  static Future<String> getDatabasePath() async {
    final path = join(await getDatabasesPath(), _dbName);
    return path;
  }
}
