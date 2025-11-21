// ignore_for_file: json_serializable
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

/// DatabaseService provides SQLite database operations for the Flutter app
/// This service demonstrates local database management with SQLite,
/// including schema creation, CRUD operations, and data relationships.
/// 
/// This service demonstrates:
/// - SQLite database initialization and management
/// - Database schema creation and versioning
/// - CRUD operations for complex data structures
/// - Search and filtering capabilities
/// - Database path management and cleanup
class DatabaseService {
  /// Static database instance for singleton pattern
  /// Ensures single database connection across the app
  static Database? _database;
  
  /// Database file name
  static const String _dbName = 'lab04_app.db';
  
  /// Database schema version for migration management
  static const int _version = 1;

  /// Get database instance, initializing if necessary
  /// Returns the database instance or creates a new one
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database
  /// Creates database file, sets up schema, and configures callbacks
  static Future<Database> _initDatabase() async {
    // Get the default databases location
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Open the database, set version, and provide onCreate and onUpgrade callbacks
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database schema on first run
  /// Defines table structures and relationships
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table with proper constraints
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create posts table with foreign key relationship to users
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Handle database schema upgrades
  /// Called when database version increases
  /// For now, this is a placeholder for future migrations
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  /// Create a new user in the database
  /// Validates input data and returns the created user with generated ID
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;

    final now = DateTime.now();
    final userMap = {
      'name': request.name.trim(),
      'email': request.email.trim(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final id = await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return User(
      id: id,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Retrieve a user by ID
  /// Returns null if user doesn't exist
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final userMap = maps.first;
      return User(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        createdAt: DateTime.parse(userMap['created_at'] as String),
        updatedAt: DateTime.parse(userMap['updated_at'] as String),
      );
    }
    return null;
  }

  /// Retrieve all users ordered by creation date
  /// Returns empty list if no users exist
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    return maps.map((userMap) => User(
      id: userMap['id'] as int,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    )).toList();
  }

  /// Update an existing user with new data
  /// Only updates provided fields and automatically updates timestamp
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;

    // Prepare the updates map and update the updated_at timestamp
    final updatedAt = DateTime.now();
    final updateData = Map<String, dynamic>.from(updates);
    updateData['updated_at'] = updatedAt.toIso8601String();

    // Update the user in the database
    await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Fetch the updated user and return
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final userMap = maps.first;
      return User(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        createdAt: DateTime.parse(userMap['created_at'] as String),
        updatedAt: DateTime.parse(userMap['updated_at'] as String),
      );
    } else {
      throw Exception('User not found');
    }
  }

  /// Delete a user by ID
  /// Also deletes related posts due to CASCADE constraint
  static Future<void> deleteUser(int id) async {
    final db = await database;

    // Delete the user by ID
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    // If you have related tables (e.g., posts, comments), consider deleting related data here.
    // For now, this only deletes the user from the users table.
  }

  /// Get total count of users in database
  /// Useful for pagination or statistics
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    } else {
      return 0;
    }
  }

  /// Search users by name or email
  /// Uses SQL LIKE operator for partial matching
  /// Returns empty list if no matches found
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final searchQuery = '%${query.trim()}%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'name ASC',
    );
    return maps.map((userMap) => User(
      id: userMap['id'] as int,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    )).toList();
  }

  /// Close the database connection
  /// Should be called when app is shutting down
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Get the database file path
  /// Useful for debugging or backup purposes
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }

  /// Clear all data from all tables
  /// Use with caution - this removes all app data
  static Future<void> clearAllData() async {
    final db = await database;

    // Delete all records from all tables
    await db.delete('posts');
    await db.delete('users');
  }
}
