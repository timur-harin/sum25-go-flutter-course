import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database> get database async {
    // TODO: Return existing database or initialize new one
    // Use the null-aware operator to check if _database exists
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // TODO: Initialize the SQLite database
    // - Get the databases path
    // - Join with database name
    // - Open database with version and callbacks
    try {
      final dbPath = await getDatabasePath();
      return await openDatabase(
        dbPath,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception('failed to initialize database: $e');
    }
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // TODO: Create tables when database is first created
    // Create users table with: id, name, email, created_at, updated_at
    // Create posts table with: id, user_id, title, content, published, created_at, updated_at
    // Include proper PRIMARY KEY and FOREIGN KEY constraints
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(30) NOT NULL,
        email VARCHAR(30) NOT NULL UNIQUE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published BOOLEAN NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
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
    // TODO: Insert user into database
    // - Get database instance
    // - Insert user data
    try {
      if (_database == null) {
        await database;
      }
      final db = _database!;
      final now = DateTime.now().toIso8601String();

      final id = await db.insert('users', {
        'name': request.name,
        'email': request.email,
        'created_at': now,
        'updated_at': now
      });
      return User(
        id: id,
        name: request.name,
        email: request.email,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(now)
      );
    } catch (e) {
      throw Exception('failed to create user: $e');
    }
  }

  // TODO: Implement getUser method
  static Future<User?> getUser(int id) async {
    // TODO: Get user by ID from database
    // - Query users table by ID
    // - Return User object or null if not found
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      final data = maps.first;
      return User.fromJson(data);
    } catch (e) {
      throw Exception('failed to get user: $e');
    }
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    // TODO: Get all users from database
    // - Query all users ordered by created_at
    // - Convert query results to User objects
    try {
      final db = await database;
      final maps = await db.query('users', orderBy: 'created_at DESC');
      return maps.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      throw Exception('failed to get all users: $e');
    }
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    // TODO: Update user in database
    // - Update user with provided data
    // - Update the updated_at timestamp
    // - Return updated User object
    try {
      final db = await database;
      updates['updated_at'] = DateTime.now().toIso8601String();
      final number = await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (number == 0) {
        throw Exception('user with id not found: $id');
      }

      final updatedUser = await getUser(id);

      if (updatedUser == null) {
        throw Exception('user with id not found: $id');
      }
      
      return updatedUser;
    } catch (e) {
      throw Exception('failed to update user: $e');
    }
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    // TODO: Delete user from database
    // - Delete user by ID
    // - Consider cascading deletes for related data
    try {
    final db = await database;
    final number = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (number == 0) {
      throw Exception('user with id not found: $id');
    }
    } catch (e) {
      throw Exception('failed to update user: $e');
    }
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    try {
      // TODO: Count total number of users
      // - Query count from users table
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('failed to get user count: $e');
    }
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    // TODO: Search users by name or email
    // - Use LIKE operator for pattern matching
    // - Search in both name and email fields
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'name LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return maps.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      throw Exception('failed to search users: $e');
    }
  }

  // Database utility methods

  // TODO: Implement closeDatabase method
  static Future<void> closeDatabase() async {
    // TODO: Close database connection
    // - Close the database if it exists
    // - Set _database to null
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // TODO: Implement clearAllData method
  static Future<void> clearAllData() async {
    // TODO: Clear all data from database (for testing)
    // - Delete all records from all tables
    // - Reset auto-increment counters if needed
    try {
      final db = await database;
      await db.delete('posts');
      await db.delete('users');
    } catch (e) {
      throw Exception('Failed to clear database: $e');
    }
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    // TODO: Get the full path to the database file
    // - Return the complete path to the database file
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }
}
