import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

/// Service for managing SQLite database operations
/// Handles user data storage with full CRUD operations and search functionality
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  /// Gets the database instance, initializing it if necessary
  /// Uses singleton pattern to ensure only one database connection
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database with proper configuration
  /// Creates the database file and sets up version control
  static Future<Database> _initDatabase() async {
    final documentsPath = await getDatabasesPath();
    final path = join(documentsPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates database tables when database is first created
  /// Sets up users and posts tables with proper constraints
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table with all required fields
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
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Handles database schema upgrades between versions
  /// Currently empty but can be extended for future migrations
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    // For now, this is empty but can be extended for future migrations
  }

  // User CRUD operations

  /// Creates a new user in the database
  /// Returns the created User object with generated ID and timestamps
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

  /// Retrieves a user by their ID
  /// Returns null if user is not found
  static Future<User?> getUser(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Retrieves all users from the database
  /// Returns users ordered by creation date (newest first)
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query(
      'users',
      orderBy: 'created_at DESC',
    );

    return result
        .map((row) => User(
              id: row['id'] as int,
              name: row['name'] as String,
              email: row['email'] as String,
              createdAt: DateTime.parse(row['created_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
            ))
        .toList();
  }

  /// Updates a user with the provided data
  /// Automatically updates the updated_at timestamp
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

    // Return updated user
    final updatedUser = await getUser(id);
    if (updatedUser == null) {
      throw Exception('User not found after update');
    }

    return updatedUser;
  }

  /// Deletes a user from the database
  /// Also deletes related posts due to CASCADE constraint
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns the total number of users in the database
  /// Useful for pagination and statistics
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return (result.first['count'] as int?) ?? 0;
  }

  /// Searches for users by name or email using LIKE pattern matching
  /// Returns users ordered by creation date (newest first)
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return result
        .map((row) => User(
              id: row['id'] as int,
              name: row['name'] as String,
              email: row['email'] as String,
              createdAt: DateTime.parse(row['created_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
            ))
        .toList();
  }

  // Database utility methods

  /// Closes the database connection and cleans up resources
  /// Should be called when the app is shutting down
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clears all data from the database
  /// Primarily used for testing and development
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('posts');
    // Reset auto-increment counters
    await db.execute(
        'DELETE FROM sqlite_sequence WHERE name IN ("users", "posts")');
  }

  /// Returns the full path to the database file
  /// Useful for debugging and file management
  static Future<String> getDatabasePath() async {
    final documentsPath = await getDatabasesPath();
    return join(documentsPath, _dbName);
  }
}
