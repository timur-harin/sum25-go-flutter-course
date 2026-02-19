import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      onUpgrade: _onUpgrade,
    );
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE users("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name VARCHAR(25) NOT NULL,"
        "email VARCHAR(25) NOT NULL,"
        "created_at INTEGER NOT NULL,"
        "updated_at INTEGER NOT NULL"
        ")");
    await db.execute("CREATE TABLE posts("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "user_id INTEGER NOT NULL,"
        "title VARCHAR(25) NOT NULL,"
        "content TEXT NOT NULL,"
        "published BOOLEAN NOT NULL,"
        "created_at INTEGER NOT NULL,"
        "updated_at INTEGER NOT NULL,"
        "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE"
        ")");
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {}

  static int currentTimeInSeconds() {
    var ms = (DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  // User CRUD operations

  // TODO: Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    var id = await db.insert("users", {
      "name": request.name,
      "email": request.email,
      "created_at": currentTimeInSeconds(),
      "updated_at": currentTimeInSeconds()
    });

    return User(
        id: id,
        name: request.name,
        email: request.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  static Future<User?> getUser(int id) async {
    final db = await database;
    final result = await db.query("users", where: "id = ?", whereArgs: [id]);
    return result.isEmpty ? null : User.fromJson(result.first);
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: "created_at");
    return result.map((json) => User.fromJson(json)).toList();
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = currentTimeInSeconds().toString();
    await db.update("users", updates, where: "id = ?", whereArgs: [id]);
    return (await getUser(id))!;
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final result = await db.query('users', where: "name LIKE ? OR email LIKE ?", whereArgs: ['%$query%', '%$query%']);
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Database utility methods

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
    await db.delete('posts');
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
