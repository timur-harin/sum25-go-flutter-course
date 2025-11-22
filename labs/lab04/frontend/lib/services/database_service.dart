import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  static Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    // - Get the databases path
    // - Join with database name
    // - Open database with version and callbacks

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table with: id, name, email, created_at, updated_at
    // Create posts table with: id, user_id, title, content, published, created_at, updated_at
    // Include proper PRIMARY KEY and FOREIGN KEY constraints

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

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

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {}

  // User CRUD operations

  static Future<User> createUser(CreateUserRequest request) async {
    // - Get database instance
    // - Insert user data
    // - Return User object with generated ID and timestamps

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

  static Future<User?> getUser(int id) async {
    // - Query users table by ID
    // - Return User object or null if not found

    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    final map = result.first;
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Future<List<User>> getAllUsers() async {
    // - Query all users ordered by created_at
    // - Convert query results to User objects

    final db = await database;
    final result = await db.query('users', orderBy: 'created_at ASC');

    return result.map((map) => User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    )).toList();
  }

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    // - Update user with provided data
    // - Update the updated_at timestamp
    // - Return updated User object

    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Add updated_at to updates
    final updatedData = Map<String, dynamic>.from(updates);
    updatedData['updated_at'] = now;

    await db.update(
      'users',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Return the updated user
    final user = await getUser(id);
    if (user == null) {
      throw Exception('User not found');
    }
    return user;
  }

  static Future<void> deleteUser(int id) async {
    // - Delete user by ID
    // - Consider cascading deletes for related data
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getUserCount() async {
    // - Query count from users table
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return result.first['count'] as int;
  }

  static Future<List<User>> searchUsers(String query) async {
    // - Use LIKE operator for pattern matching
    // - Search in both name and email fields
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at ASC',
    );

    return result.map((map) => User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    )).toList();
  }

  // Database utility methods

  static Future<void> closeDatabase() async {
    // - Close the database if it exists
    // - Set _database to null
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    // - Delete all records from all tables
    // - Reset auto-increment counters if needed
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  static Future<String> getDatabasePath() async {
    // - Return the complete path to the database file
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}