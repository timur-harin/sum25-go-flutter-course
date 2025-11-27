import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Getter for the database instance, initializes if null
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // Initialize the database if it's not opened yet
    _database = await _initDatabase();
    return _database!;
  }

  // Initializes the SQLite database with path, version, and callbacks
  static Future<Database> _initDatabase() async {
    // Get the default database directory path
    final databasesPath = await getDatabasesPath();
    // Compose full path to the database file
    final path = join(databasesPath, _dbName);
    // Open the database, create if not exists
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Called when the database is created for the first time
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table with id, name, email, created_at, updated_at
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create posts table with proper foreign key constraint on user_id
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Called when the database version is upgraded
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement schema migration logic here if needed
  }

  // Inserts a new user and returns the created User object
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Insert user data into users table
    final id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now,
      'updated_at': now,
    });

    // Return user with assigned ID and timestamps
    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  // Retrieves a user by ID, returns null if not found
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    return User(
      id: data['id'] as int,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Returns all users ordered by creation date
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at');

    return maps.map((data) {
      return User(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }).toList();
  }

  // Updates user fields and returns updated User object
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;

    // Update the updated_at timestamp
    updates['updated_at'] = DateTime.now().toIso8601String();

    // Perform update operation
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Return updated user
    final updatedUser = await getUser(id);
    if (updatedUser == null) {
      throw Exception('User not found after update');
    }
    return updatedUser;
  }

  // Deletes a user by ID
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Counts total number of users in database
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Searches users by name or email using LIKE operator
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final pattern = '%$query%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [pattern, pattern],
    );

    return maps.map((data) {
      return User(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }).toList();
  }

  // Closes the database connection and sets instance to null
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clears all data from users and posts tables (for testing)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('posts');
    await db.delete('users');
  }

  // Returns full path to the database file
  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbName);
  }
}
