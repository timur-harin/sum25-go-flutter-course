import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // ───────────────────────────────────────── getter ──
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ───────────────────────────────────────── init DB ──
  static Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path  = p.join(dbDir, _dbName);

    return openDatabase(
      path,
      version: _version,
      onCreate : _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ───────────────────────────────────────── schema ──
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT NOT NULL,
        email       TEXT NOT NULL UNIQUE,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE posts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        title       TEXT NOT NULL,
        content     TEXT,
        published   INTEGER DEFAULT 0,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // миграций пока нет
  }

  // ───────────────────────────────────────── mapping ──
  static User _map(Map<String, Object?> row) => User(
        id       : row['id'] as int,
        name     : row['name'] as String,
        email    : row['email'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );

  // ───────────────────────────────────────── CRUD ──
  static Future<User> createUser(CreateUserRequest req) async {
    final db  = await database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('users', {
      'name'      : req.name.trim(),
      'email'     : req.email.trim(),
      'created_at': now,
      'updated_at': now,
    });

    return User(
      id       : id,
      name     : req.name.trim(),
      email    : req.email.trim(),
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  static Future<User?> getUser(int id) async {
    final db   = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _map(rows.first);
  }

  static Future<List<User>> getAllUsers() async {
    final db   = await database;
    final rows = await db.query('users', orderBy: 'created_at');
    return rows.map(_map).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) throw ArgumentError('updates cannot be empty');

    final db  = await database;
    final now = DateTime.now().toIso8601String();

    // работаем с копией, чтобы не портить оригинальную Map из теста
    final data = Map<String, dynamic>.from(updates)..['updated_at'] = now;

    final affected = await db.update('users', data, where: 'id = ?', whereArgs: [id]);
    if (affected == 0) throw Exception('User not found');

    // точно возвращаем свежие данные
    final fresh = await getUser(id);
    if (fresh == null) throw Exception('User not found after update');
    return fresh;
  }

  static Future<void> deleteUser(int id) async {
    final db       = await database;
    final affected = await db.delete('users', where: 'id = ?', whereArgs: [id]);
    if (affected == 0) throw Exception('User not found');
  }

  // ─────────────────────────────────── агрегаты/поиск ──
  static Future<int> getUserCount() async {
    final db  = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS cnt FROM users');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db       = await database;
    final pattern  = '%$query%';
    final rows = await db.query(
      'users',
      where    : 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy  : 'created_at',
    );
    return rows.map(_map).toList();
  }

  // ─────────────────────────────────── служебные ──
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
  }

  static Future<String> getDatabasePath() async {
    final dbDir = await getDatabasesPath();
    return p.join(dbDir, _dbName);
  }
}
