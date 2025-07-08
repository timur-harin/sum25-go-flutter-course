import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';

class DatabaseService {
  static const _dbName = 'lab04_app.db';
  static const _version = 1;
  static const _userTable = 'users';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<User> createUser(CreateUserRequest req) async {
    final db = await database;
    final now = DateTime.now().toUtc();
    final id = await db.insert(_userTable, {
      'name': req.name,
      'email': req.email,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    return User(
      id: id,
      name: req.name,
      email: req.email,
      createdAt: now,
      updatedAt: now,
    );
  }

  static Future<User?> getUser(int id) async {
    final db = await database;
    final rows =
        await db.query(_userTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _mapToUser(rows.first);
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final rows = await db.query(_userTable, orderBy: 'id ASC');
    return rows.map(_mapToUser).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await db.update(_userTable, updates, where: 'id = ?', whereArgs: [id]);
    final fresh = await getUser(id);
    if (fresh == null) {
      throw StateError('User with id=$id not found');
    }
    return fresh;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(_userTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getUserCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM $_userTable');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final pattern = '%$query%';
    final rows = await db.query(
      _userTable,
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'id ASC',
    );
    return rows.map(_mapToUser).toList();
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_userTable);
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: [_userTable]);
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }

  static User _mapToUser(Map<String, Object?> row) {
    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}