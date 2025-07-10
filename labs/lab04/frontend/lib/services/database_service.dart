import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import 'dart:async';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  /// Получить/инициализировать базу данных
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Инициализация базы
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Создание таблиц при первом запуске базы
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
  }

  /// Миграции (пока пусто)
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Логика миграций по необходимости
  }

  /// Создать пользователя
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;

    final nowIso = DateTime.now().toIso8601String();
    final id = await db.insert(
      'users',
      {
        'name': request.name.trim(),
        'email': request.email.trim(),
        'created_at': nowIso,
        'updated_at': nowIso,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final userMap = await db.query('users', where: 'id = ?', whereArgs: [id]);

    return User.fromJson(userMap.first);
  }

  /// Получить пользователя по ID
  static Future<User?> getUser(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;

    return User.fromJson(result.first);
  }

  /// Получить всех пользователей
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_at');
    return result.map((map) => User.fromJson(map)).toList();
  }

  /// Обновить пользователя
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    if (updates.isEmpty) {
      throw ArgumentError('No fields to update');
    }

    updates['updated_at'] = DateTime.now().toIso8601String();

    final count = await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      throw Exception('User not found');
    }

    final updated = await getUser(id);
    if (updated == null) {
      throw Exception('Failed to fetch updated user');
    }
    return updated;
  }

  /// Удалить пользователя
  static Future<void> deleteUser(int id) async {
    final db = await database;
    final count = await db.delete('users', where: 'id = ?', whereArgs: [id]);
    if (count == 0) {
      throw Exception('User not found');
    }
  }

  /// Подсчитать количество пользователей
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Поиск пользователей по имени или email (LIKE)
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final pattern = '%${query.trim()}%';
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'created_at',
    );
    return result.map((map) => User.fromJson(map)).toList();
  }

  /// Закрыть базу
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Очистить все данные (для тестов)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  /// Получить полный путь к базе
  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }
}
