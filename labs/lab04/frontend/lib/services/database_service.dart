import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  // TODO: Implement createUser method
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

  // TODO: Implement getUser method
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final m = maps[0];
      return User(
        id: m['id'] is int ? m['id'] as int : int.parse(m['id'].toString()),
        name: m['name'] as String,
        email: m['email'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );
    }
    return null;
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at');
    return maps.map((m) => User(
      id: m['id'] is int ? m['id'] as int : int.parse(m['id'].toString()),
      name: m['name'] as String,
      email: m['email'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    )).toList();
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    // Only update fields that are present and not null
    final filteredUpdates = <String, dynamic>{};
    if (updates.containsKey('name') && updates['name'] != null) {
      filteredUpdates['name'] = updates['name'];
    }
    if (updates.containsKey('email') && updates['email'] != null) {
      filteredUpdates['email'] = updates['email'];
    }
    filteredUpdates['updated_at'] = DateTime.now().toIso8601String();
    await db.update('users', filteredUpdates, where: 'id = ?', whereArgs: [id]);
    final user = await getUser(id);
    if (user == null) throw Exception('User not found');
    return user;
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at',
    );
    return maps.map((m) => User(
      id: m['id'] is int ? m['id'] as int : int.parse(m['id'].toString()),
      name: m['name'] as String,
      email: m['email'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    )).toList();
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
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
