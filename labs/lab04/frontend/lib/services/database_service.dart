import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  // TODO: Implement _initDatabase method
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

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create posts table  
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    // For now, this is empty but can be extended for future migrations
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
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    final map = maps.first;
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    
    return maps.map((map) => User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    )).toList();
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Add updated_at timestamp to updates
    final updateData = Map<String, dynamic>.from(updates);
    updateData['updated_at'] = now;
    
    await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Return the updated user
    final updatedUser = await getUser(id);
    return updatedUser!;
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users'
    );
    return result.first['count'] as int;
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at ASC',
    );
    
    return maps.map((map) => User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
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
    await db.delete('posts');
    await db.delete('users');
    // Reset auto-increment counters
    await db.rawQuery('DELETE FROM sqlite_sequence WHERE name IN ("users", "posts")');
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
