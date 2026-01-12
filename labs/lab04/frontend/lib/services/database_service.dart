import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  static const String _tableUsers = 'users';
  static const String _tablePosts = 'posts';

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
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableUsers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tablePosts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Migration logic can be added here in the future
  }

  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final userData = {
      'name': request.name,
      'email': request.email,
      'created_at': now,
      'updated_at': now,
    };

    final id = await db.insert(_tableUsers, userData,
        conflictAlgorithm: ConflictAlgorithm.replace);

    final userMap = await db.query(_tableUsers, where: 'id = ?', whereArgs: [id]);
    return User.fromJson(userMap.first);
  }

  static Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableUsers,
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
    final List<Map<String, dynamic>> maps = await db.query(
      _tableUsers,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final Map<String, dynamic> dataToUpdate = Map.from(updates);
    dataToUpdate['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      _tableUsers,
      dataToUpdate,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    final updatedUser = await getUser(id);
    if(updatedUser == null) {
      throw Exception('User not found after update');
    }
    return updatedUser;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      _tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getUserCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableUsers'));
    return count ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableUsers,
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tablePosts);
    await db.delete(_tableUsers);
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}