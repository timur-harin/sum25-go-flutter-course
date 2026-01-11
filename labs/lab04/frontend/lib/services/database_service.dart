import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // Implement database getter
  static Future<Database> get database async {
    // Return existing database or initialize new one
    // Use the null-aware operator to check if _database exists
    _database ??= await _initDatabase();
    return _database!;
  }

  // Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // Initialize the SQLite database
    // - Get the databases path
    final dbPath = await getDatabasesPath();
    // - Join with database name
    final path = join(dbPath, _dbName);
    // - Open database with version and callbacks
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  // Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // Create tables when database is first created
    // Create users table with: id, name, email, created_at, updated_at
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    // Create posts table with: id, user_id, title, content, published, created_at, updated_at
    // Include proper PRIMARY KEY and FOREIGN KEY constraints
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        published BOOLEAN DEFAULT 0,
        created_at INTEGER NOT NULL,
        update_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_posts_user_id ON posts(user_id)');
  }

  // Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  // Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    // Insert user into database
    // - Get database instance
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // - Insert user data
    final id = await db.insert('users', {
      'name': request.name,
      'email': request.email,
      'created_at': now,
      'updated_at': now,
    });
    // - Return User object with generated ID and timestamps
    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  // Implement getUser method
  static Future<User?> getUser(int id) async {
    // Get user by ID from database
    // - Query users table by ID
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    // - Return User object or null if not found
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    // Get all users from database
    // - Query all users ordered by created_at
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at DESC',
    );
    // - Convert query results to User objects
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  // Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    // Update user in database
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    // - Update the updated_at timestamp
     final dbUpdates = <String, dynamic>{
    'updated_at': now, // Keep as int for database
    };
    
    if (updates.containsKey('name')) {
      dbUpdates['name'] = updates['name'] as String;
    }
    if (updates.containsKey('email')) {
      dbUpdates['email'] = updates['email'] as String;
    }
    // - Update user with provided data
    await db.update(
      'users',
      dbUpdates,
      where: 'id = ?',
      whereArgs: [id],
    );
    // - Return updated User object
    final updatedUser = await getUser(id);
    return updatedUser!;
  }

  // Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    // Delete user from database
    // - Delete user by ID
    // - Consider cascading deletes for related data
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Implement getUserCount method
  static Future<int> getUserCount() async {
    // Count total number of users
    // - Query count from users table
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    );
    return count ?? 0;
  }

  // Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    // Search users by name or email
    // - Use LIKE operator for pattern matching
    // - Search in both name and email fields
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  // Database utility methods

  // Implement closeDatabase method
  static Future<void> closeDatabase() async {
    // Close database connection
    // - Close the database if it exist
    // - Set _database to null
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Implement clearAllData method
  static Future<void> clearAllData() async {
    // Clear all data from database (for testing)
    // - Delete all records from all tables
    // - Reset auto-increment counters if needed
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('posts');
      await txn.delete('users');
    });
  }

  // Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    // Get the full path to the database file
    // - Return the complete path to the database file
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
