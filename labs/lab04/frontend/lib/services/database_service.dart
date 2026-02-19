import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Геттер для базы данных
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Инициализация базы данных
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

  // Создание таблиц при первом создании базы данных
  static Future<void> _onCreate(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Таблица постов
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
      )
    ''');
  }

  // Обработка обновления схемы базы данных
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Пока миграций нет, оставим пустым
  }

  // CRUD операции для пользователя

  // Создание пользователя
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toUtc();
    final userMap = {
      'name': request.name,
      'email': request.email,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    final id = await db.insert('users', userMap);
    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Получение пользователя по id
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Получение всех пользователей
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // Обновление пользователя
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final now = DateTime.now().toUtc();
    updates['updated_at'] = now.toIso8601String();
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    final updatedUser = await getUser(id);
    if (updatedUser == null) {
      throw Exception('Пользователь не найден');
    }
    return updatedUser;
  }

  // Удаление пользователя
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Если нужно каскадное удаление постов, FOREIGN KEY ON DELETE CASCADE уже настроен
  }

  // Получение количества пользователей
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Поиск пользователей по имени или email
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final likeQuery = '%$query%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [likeQuery, likeQuery],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => User.fromJson(map)).toList();
  }

  // Утилиты базы данных

  // Закрытие соединения с базой данных
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Очистка всех данных из базы данных (для тестирования)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
    // Сброс автоинкремента (SQLite)
    await db.execute('DELETE FROM sqlite_sequence WHERE name="users"');
    await db.execute('DELETE FROM sqlite_sequence WHERE name="posts"');
  }

  // Получение полного пути к файлу базы данных
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
