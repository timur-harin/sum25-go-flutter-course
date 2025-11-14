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
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
  }

  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now();
    final id = await db.insert(
      'users',
      {
        'name': request.name,
        'email': request.email,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      },
    );
    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
    );
  }

  static Future<User?> getUser(int id) async {
  final db = await database;
  final maps = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  if (maps.isEmpty) return null;
  final map = maps.first;
  return User(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
  );
}

  static Future<List<User>> getAllUsers() async {
    final db = await database;
  final maps = await db.query('users', orderBy: 'created_at DESC');
  
  return maps.map((map) => User(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
  )).toList();
}

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
  final db = await database;
  final now = DateTime.now();
  
  final safeUpdates = Map<String, dynamic>.from(updates);
  safeUpdates['updated_at'] = now.millisecondsSinceEpoch;
  
  await db.update(
    'users',
    safeUpdates,
    where: 'id = ?',
    whereArgs: [id],
  );
  return (await getUser(id))!;
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
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return count ?? 0;
  }

  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
  final searchTerm = '%$query%';
  final maps = await db.query(
    'users',
    where: 'name LIKE ? OR email LIKE ?',
    whereArgs: [searchTerm, searchTerm],
  );
  
  return maps.map((map) => User(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
  )).toList();
}

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('posts');
      await txn.delete('users');
    });
  }

  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }
}
