import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;


  static Future<Database> get database async {
    // Use the null-aware operator to check if _database exists
    _database ??= await _initDatabase();
    return _database!;
  }


  static Future<Database> _initDatabase() async {
    // - Get the databases path
    // - Join with database name
    // - Open database with version and callbacks
    final dbPath = await getDatabasePath();
    final path = join(dbPath, _dbName);
    return await openDatabase (
        path,
        version: _version,
        onCreate: _onCreate
    );
  }


  static Future<void> _onCreate(Database db, int version) async {
    // Create users table with: id, name, email, created_at, updated_at
    // Create posts table with: id, user_id, title, content, published, created_at, updated_at
    // Include proper PRIMARY KEY and FOREIGN KEY constraints
    await db.execute(''' 
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
email TEXT UNIQUE NOT NULL,
created_at INTEGER NOT NULL,
updated_at INTEGER NOT NULL
)
''');
   await db.execute(''' 
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  published INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
''');
  await db.execute('CREATE INDEX idx_posts_user_id ON posts(user_id)');
  }


  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  static Future<User> createUser(CreateUserRequest request) async {
    // - Get database instance
    // - Insert user data
    // - Return User object with generated ID and timestamps
    final db = await database;
    final time = DateTime.now().toIso8601String();
    final id = await db.insert( 'users', {
      'name': request.name,
      'email': request.email,
      'created_at': time,
      'updated_at': time,
    });
    return User(
      id: id,
      name: request.name,
      email: request.email,
      createdAt: DateTime.parse(time),
      updatedAt: DateTime.parse(time),
    );
  }

  static Future<User?> getUser(int id) async {
    // - Query users table by ID
    // - Return User object or null if not found
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


  static Future<List<User>> getAllUsers() async {
    // - Query all users ordered by created_at
    // - Convert query results to User objects
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

  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    // - Update user with provided data
    // - Update the updated_at timestamp
    // - Return updated User object
    final db = await database;
    final filteredUpdates = <String, dynamic>{};
    if (updates.containsKey('email') && updates['email'] != null) {
      filteredUpdates['email'] = updates['email'];
    }
    if (updates.containsKey('name') && updates['name'] != null) {
      filteredUpdates['name'] = updates['name'];
    }
    filteredUpdates['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'users',
      filteredUpdates,
      where: 'id = ?',
      whereArgs: [id]
    );
    final user = await getUser(id);
    if (user == null) throw Exception('User not douns');
    return user;
  }


  static Future<void> deleteUser(int id) async {
    // - Delete user by ID
    // - Consider cascading deletes for related data
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getUserCount() async {
    // - Query count from users table
    final db = await database;
	  final count = await db.rawQuery('SELECT COUNT(*) as count FROM users'); // counts how many rows are in the users table
	  return Sqflite.firstIntValue(count) ?? 0; // extracts the first integer value from the result list.
  }


  static Future<List<User>> searchUsers(String query) async {
    // - Use LIKE operator for pattern matching
    // - Search in both name and email fields
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
    await db.delete('users');
  }


  static Future<String> getDatabasePath() async {
    // - Return the complete path to the database file
    final databasePath = await getDatabasesPath();
    return 'lab04_app.db/app_database.db';
  }
}
