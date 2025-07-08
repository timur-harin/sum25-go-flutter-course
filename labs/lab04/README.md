# Lab 04: Database & Persistence

Welcome to Lab 04! In this lab, you'll learn about database fundamentals and implement persistence solutions in both Go and Flutter applications.

## 🎯 Lab Overview

This lab introduces **Database & Persistence** concepts by implementing data storage solutions in both Go (backend) and Flutter (frontend).

### 🔧 Database Approaches Covered

This lab demonstrates **4 different approaches** to database interaction in Go, allowing you to compare and contrast different patterns:

#### 1. **Manual SQL** (`user_repository.go`) 
- **Approach**: Raw SQL queries with `database/sql` package
- **Pros**: Maximum control, best performance, clear SQL queries
- **Cons**: More boilerplate, manual row scanning, SQL injection risk
- **Use Case**: When you need precise control over queries and performance

#### 2. **Scany Mapping** (`post_repository.go`)
- **Approach**: Raw SQL queries + automatic struct mapping 
- **Library**: `github.com/georgysavva/scany/v2/sqlscan`
- **Pros**: Eliminates manual scanning, type-safe, good performance
- **Cons**: Still requires SQL knowledge, limited query building
- **Use Case**: When you want SQL control but easier result mapping

#### 3. **Squirrel Query Builder** (`search_service.go`)
- **Approach**: Dynamic query building with fluent API
- **Library**: `github.com/Masterminds/squirrel`
- **Pros**: Type-safe query building, dynamic conditions, readable code
- **Cons**: Learning curve, abstraction overhead
- **Use Case**: When you need dynamic queries with many conditional filters

#### 4. **GORM ORM** (`category_repository.go`)
- **Approach**: Full Object-Relational Mapping
- **Library**: `gorm.io/gorm`
- **Pros**: Rapid development, automatic migrations, associations
- **Cons**: Less control, potential N+1 queries, steeper learning curve
- **Use Case**: When you want rapid development and don't mind abstraction

### 🎯 What You'll Learn

Compare these approaches by implementing similar functionality:
- **Performance**: Benchmark different approaches
- **Code Complexity**: See boilerplate vs. abstraction trade-offs
- **Type Safety**: Experience compile-time vs. runtime error detection
- **Maintainability**: Understand long-term code maintenance implications

### 🏗️ Project Structure

```
lab04/
├── backend/           # Go backend with database operations
│   ├── models/        # User and Post data models
│   ├── database/      # Database connection and migrations
│   ├── repository/    # CRUD operations and data access
│   ├── main.go        # Application entry point
│   └── go.mod         # Go dependencies
├── frontend/          # Flutter frontend with local storage
│   ├── lib/
│   │   ├── models/    # Dart data models
│   │   ├── services/  # Storage services
│   │   └── screens/   # UI screens
│   ├── test/          # Unit tests
│   └── pubspec.yaml   # Flutter dependencies
└── README.md          # This file
```

## 🔧 Setup Instructions

### Backend Setup (Go)

1. Navigate to the backend directory:
```bash
cd labs/lab04/backend
```

2. Install dependencies:
```bash
go mod tidy
```

3. Run the application:
```bash
go run main.go
```

4. Run tests:
```bash
go test ./...
```

### Frontend Setup (Flutter)

1. Navigate to the frontend directory:
```bash
cd labs/lab04/frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate JSON serialization code:
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

5. Run tests:
```bash
flutter test
```

## 📝 Tasks Overview

### Go Backend Tasks - Multiple Database Approaches

Lab 4 covers **multiple database approaches** with **3 NECESSARY tasks** for evaluation plus **additional OPTIONAL tasks** for deeper learning:

---

#### ✅ **NECESSARY TASKS** (Required for Lab Completion)

#### Task 1: Manual SQL Repository (`user_repository.go`) 🔴 **REQUIRED**
**Approach:** Raw SQL with `database/sql` package ⚡

- ✅ **Maximum Control**: Write your own SQL queries
- ✅ **Best Performance**: No ORM overhead
- ✅ **Manual Scanning**: Explicit row-to-struct mapping

**TODO Items:**
- `UserRepository.Create()` - Raw SQL INSERT with parameter binding
- `UserRepository.GetByID()` - Manual SELECT with row.Scan()
- `UserRepository.Update()` - Dynamic UPDATE with prepared statements
- `User.ScanRow()` - Manual database row scanning

#### Task 2: Database Infrastructure (`database/connection.go`, `database/migrations.go`) 🔴 **REQUIRED**
**Approach:** Standard database setup with goose migrations 🏗️

- ✅ **Connection Management**: Proper database connection pooling
- ✅ **Migration System**: Goose-based schema management
- ✅ **Production Ready**: Configurable and maintainable setup

**TODO Items:**
- `InitDB()` - Standard database/sql connection setup
- `RunMigrations()` - Execute goose migrations programmatically
- Connection pooling configuration and management
- **Makefile Commands**: `make migrate-up`, `make migrate-down`, `make migrate-status`

#### Task 3: Data Models (`models/user.go`, `models/post.go`) 🔴 **REQUIRED**  
**Approach:** Go structs with manual validation and mapping 📦

- ✅ **Struct Design**: Proper JSON tags and database mapping
- ✅ **Validation**: Input validation for data integrity
- ✅ **Manual Mapping**: Row scanning and data conversion

**TODO Items:**
- `User.Validate()` - Data validation logic
- `CreateUserRequest.ToUser()` - Request to model conversion
- `User.ScanRow()` - Database row to struct mapping
- Similar patterns for Post model

---

#### 🎯 **OPTIONAL TASKS** (For Advanced Learning)

#### Task 4: Scany Mapping Repository (`post_repository.go`) 🟡 **OPTIONAL**
**Approach:** Raw SQL + automatic struct mapping 🔄

- ✅ **SQL Control**: Write SQL, skip manual scanning
- ✅ **Type Safety**: Automatic struct mapping with validation
- ✅ **Good Performance**: Minimal reflection overhead

**TODO Items:**
- `PostRepository.Create()` - Use `sqlscan.Get()` for RETURNING queries
- `PostRepository.GetAll()` - Use `sqlscan.Select()` for slice mapping
- `PostRepository.Search()` - Complex WHERE with automatic scanning

#### Task 5: Squirrel Query Builder (`search_service.go`) 🟡 **OPTIONAL**
**Approach:** Dynamic query building with fluent API 🏗️

- ✅ **Dynamic Queries**: Build complex queries programmatically
- ✅ **Type Safety**: Compile-time query validation
- ✅ **Readable Code**: Fluent API instead of string concatenation

**TODO Items:**
- `SearchService.SearchPosts()` - Dynamic filters with Squirrel
- `SearchService.GetPostStats()` - Complex JOINs and aggregation
- `SearchService.BuildDynamicQuery()` - Modular query building

#### Task 6: GORM ORM Repository (`category_repository.go`) 🟡 **OPTIONAL**
**Approach:** Full Object-Relational Mapping 🚀

- ✅ **Rapid Development**: High-level database operations
- ✅ **Auto Relationships**: Preload associations automatically
- ✅ **Model Hooks**: Lifecycle management with hooks

**TODO Items:**
- `CategoryRepository.Create()` - GORM Create with auto-timestamps
- `CategoryRepository.GetCategoriesWithPosts()` - GORM Preload
- `Category.BeforeCreate()` - GORM lifecycle hooks
- `CategoryRepository.CreateWithTransaction()` - GORM transactions

---

#### 📚 **Why Multiple Approaches?**

| Approach | Performance | Development Speed | Learning Value | Production Use |
|----------|-------------|-------------------|----------------|----------------|
| **Manual SQL** ⚡ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | High-performance apps |
| **Scany Mapping** 🔄 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Balanced control+convenience |
| **Squirrel Builder** 🏗️ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Dynamic query scenarios |
| **GORM ORM** 🚀 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Rapid prototyping |

**Focus on the 3 NECESSARY tasks first, then explore OPTIONAL ones based on interest!**

### Flutter Frontend Tasks

#### Task 4: SharedPreferences Service 🔴 **REQUIRED**
**File:** `frontend/lib/services/preferences_service.dart`

Implement simple key-value storage:

- ✅ **Basic Operations**: String, int, bool, list storage
- ✅ **Object Storage**: JSON serialization for complex objects
- ✅ **Key Management**: Check existence, get all keys, clear data
- ✅ **Type Safety**: Proper null handling and type conversion

**TODO Items to Complete:**
- `init()` - Initialize SharedPreferences instance
- `setString()`, `getString()` - String value operations
- `setInt()`, `getInt()` - Integer value operations
- `setBool()`, `getBool()` - Boolean value operations
- `setStringList()`, `getStringList()` - String list operations
- `setObject()`, `getObject()` - JSON object operations
- `remove()`, `clear()` - Data cleanup operations
- `containsKey()`, `getAllKeys()` - Key management

#### Task 5: SQLite Database Service 🔴 **REQUIRED**
**File:** `frontend/lib/services/database_service.dart`

Implement local SQLite database:

- ✅ **Database Setup**: Initialize SQLite with proper schema
- ✅ **User CRUD**: Complete user operations
- ✅ **Search Functionality**: Query users by name/email
- ✅ **Database Management**: Path management, cleanup, migrations

**TODO Items to Complete:**
- `database` getter - Return database instance or initialize
- `_initDatabase()` - Initialize SQLite database
- `_onCreate()` - Create database tables and schema
- `createUser()` - Insert user into database
- `getUser()` - Get user by ID
- `getAllUsers()` - Get all users ordered by creation
- `updateUser()` - Update user with dynamic fields
- `deleteUser()` - Delete user from database
- `getUserCount()` - Count total users
- `searchUsers()` - Search users by name/email
- `closeDatabase()`, `clearAllData()` - Database management
- `getDatabasePath()` - Get database file path

#### Task 6: Secure Storage Service 🔴 **REQUIRED**
**File:** `frontend/lib/services/secure_storage_service.dart`

Implement encrypted storage for sensitive data:

- ✅ **Authentication**: Token and credential storage
- ✅ **User Preferences**: Biometric and security settings
- ✅ **Generic Storage**: Custom key-value secure storage
- ✅ **Object Storage**: Encrypted JSON object storage
- ✅ **Key Management**: List keys, check existence, export data

**TODO Items to Complete:**
- `saveAuthToken()`, `getAuthToken()` - Authentication token management
- `deleteAuthToken()` - Remove authentication token
- `saveUserCredentials()`, `getUserCredentials()` - Login credentials
- `deleteUserCredentials()` - Remove stored credentials
- `saveBiometricEnabled()`, `isBiometricEnabled()` - Biometric settings
- `saveSecureData()`, `getSecureData()` - Generic secure storage
- `deleteSecureData()` - Remove secure data by key
- `saveObject()`, `getObject()` - Encrypted object storage
- `containsKey()`, `getAllKeys()` - Key management
- `clearAll()` - Remove all secure data
- `exportData()` - Export all data (for backup)

## 🧪 Testing

### Go Tests

```bash
# Run all tests
go test ./...

# Run specific package tests
go test ./models
go test ./database
go test ./repository

# Run tests with verbose output
go test -v ./...
```

### Flutter Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/preferences_service_test.dart
flutter test test/database_service_test.dart
flutter test test/secure_storage_service_test.dart

# Run tests with coverage
flutter test --coverage
```

## 💡 Implementation Tips

### Go Backend

1. **Database Connection**: Use connection pooling for production
2. **SQL Injection**: Always use prepared statements
3. **Error Handling**: Return appropriate error types
4. **Validation**: Validate data before database operations
5. **Transactions**: Use transactions for related operations

### Flutter Frontend

1. **Initialization**: Initialize services in main() before runApp()
2. **Error Handling**: Handle storage exceptions gracefully
3. **Type Safety**: Use proper null safety patterns
4. **Performance**: Use batch operations for multiple inserts
5. **Security**: Never store sensitive data in SharedPreferences

## 🎨 Storage Patterns

### When to Use Each Storage Type

| Storage Type | Use Cases | Examples |
|--------------|-----------|----------|
| **SharedPreferences** | Simple settings, flags | Theme, language, user preferences |
| **SQLite** | Structured data, relationships | Users, posts, complex queries |
| **Secure Storage** | Sensitive information | Tokens, passwords, API keys |

### Data Flow Patterns

1. **Cache-First**: Check local storage before API calls
2. **API-First**: Always fetch from server, cache locally
3. **Offline-First**: Work offline by default, sync when online

## 🔒 Security Considerations

1. **Never store sensitive data in SharedPreferences**
2. **Use Secure Storage for authentication tokens**
3. **Validate all user input before storage**
4. **Use proper encryption for sensitive local data**
5. **Implement proper session management**

## 🚀 Bonus Challenges

1. **Advanced Queries**: Implement complex SQL queries with joins
2. **Migration System**: Add database schema versioning
3. **Sync Mechanism**: Implement offline-first with sync
4. **Caching Strategy**: Add intelligent caching layer
5. **Performance Monitoring**: Add query performance tracking

## 📖 Resources

- [Go database/sql Documentation](https://pkg.go.dev/database/sql)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Flutter SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Flutter sqflite](https://pub.dev/packages/sqflite)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 🎯 Success Criteria

Your lab is complete when:
- ✅ All Go tests pass (models, database, repository)
- ✅ All Flutter tests pass (preferences, database, secure storage)
- ✅ You can create, read, update, and delete data in both backends
- ✅ You understand the trade-offs between different storage types
- ✅ You can implement basic data synchronization patterns

## 🆘 Getting Help

If you're stuck:
1. Check the TODO comments in the code for guidance
2. Review the test files to understand expected behavior
3. Consult the documentation links above
4. Ask questions in the course discussion forum

Good luck, and enjoy learning about database and persistence patterns! 🎉 