# Lab 04: Database & Persistence Operations

Welcome to Lab 04! This lab demonstrates comprehensive database and persistence solutions in both Go (backend) and Flutter (frontend) applications.

## 🎯 Lab Overview

Lab 04 focuses on **Database & Persistence** concepts by implementing multiple data storage approaches and patterns. You'll learn about different database interaction methods, local storage solutions, and how to build robust data layers.

### 🔧 Database Approaches Implemented

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

- **Database Design**: SQLite schema design with proper relationships
- **Migration Management**: Using Goose for database versioning
- **Repository Pattern**: Clean separation of data access logic
- **Local Storage**: SharedPreferences and SecureStorage in Flutter
- **Data Validation**: Input validation and error handling
- **Testing**: Comprehensive unit tests for data layers

### 🏗️ Project Structure

```
lab04/
├── backend/                    # Go backend with database operations
│   ├── models/                 # Data models with validation
│   │   ├── user.go            # User model with GORM hooks
│   │   ├── post.go            # Post model with relationships
│   │   └── category.go        # Category model with GORM
│   ├── database/              # Database connection and migrations
│   │   ├── connection.go      # Connection management
│   │   └── migrations.go      # Goose migration system
│   ├── repository/            # Data access layer
│   │   ├── user_repository.go # Manual SQL approach
│   │   ├── post_repository.go # Scany mapping approach
│   │   ├── category_repository.go # GORM approach
│   │   └── search_service.go  # Squirrel query builder
│   ├── migrations/            # SQL migration files
│   │   ├── 20250708090008_create_users_table.sql
│   │   ├── 20250708090034_create_posts_table.sql
│   │   └── 20250708090055_create_categories_table.sql
│   ├── main.go               # Application entry point
│   └── go.mod                # Go dependencies
├── frontend/                  # Flutter frontend with local storage
│   ├── lib/
│   │   ├── models/           # Dart data models
│   │   │   └── user.dart     # User model with JSON serialization
│   │   ├── services/         # Storage services
│   │   │   ├── database_service.dart    # SQLite operations
│   │   │   ├── preferences_service.dart # SharedPreferences
│   │   │   └── secure_storage_service.dart # Secure storage
│   │   └── screens/          # UI screens
│   ├── test/                 # Unit tests
│   │   ├── database_service_test.dart
│   │   ├── preferences_service_test.dart
│   │   └── secure_storage_service_test.dart
│   ├── build.yaml            # Build configuration
│   └── pubspec.yaml          # Flutter dependencies
└── README.md                 # This file
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
dart run build_runner build
```

4. Run the app:
```bash
flutter run
```

5. Run tests:
```bash
flutter test
```

## 📝 Implemented Features

### Backend Features

#### Database Infrastructure
- ✅ **SQLite Database**: Lightweight, file-based database
- ✅ **Connection Pooling**: Configurable connection management
- ✅ **Migration System**: Goose-based schema versioning
- ✅ **Multiple Approaches**: 4 different database interaction patterns

#### Data Models
- ✅ **User Model**: With validation, GORM hooks, and manual scanning
- ✅ **Post Model**: With relationships and scany mapping
- ✅ **Category Model**: With GORM ORM features
- ✅ **Request/Response Structs**: Clean API contracts

#### Repository Layer
- ✅ **User Repository**: Manual SQL with database/sql
- ✅ **Post Repository**: Scany mapping for automatic struct binding
- ✅ **Category Repository**: GORM ORM with hooks and scopes
- ✅ **Search Service**: Squirrel query builder for dynamic queries

### Frontend Features

#### Local Storage
- ✅ **SharedPreferences Service**: Simple key-value storage
- ✅ **Secure Storage Service**: Encrypted storage (with Linux fallback)
- ✅ **Database Service**: SQLite operations for complex data
- ✅ **JSON Serialization**: Automatic model serialization

#### Data Models
- ✅ **User Model**: With JSON serialization and validation
- ✅ **Request Models**: For API communication
- ✅ **Copy Methods**: For immutable data handling

#### Testing
- ✅ **Unit Tests**: Comprehensive test coverage
- ✅ **Service Tests**: Storage service validation
- ✅ **Model Tests**: Data validation testing

## 🚀 Key Learning Outcomes

### Database Patterns
1. **Manual SQL**: Understand raw database operations
2. **Query Builders**: Learn dynamic query construction
3. **ORM Mapping**: Experience high-level abstractions
4. **Migration Management**: Version control for database schemas

### Flutter Persistence
1. **SharedPreferences**: Simple local storage
2. **Secure Storage**: Encrypted data storage
3. **SQLite**: Complex local database operations
4. **JSON Serialization**: Data model handling

### Best Practices
1. **Repository Pattern**: Clean data access separation
2. **Validation**: Input validation and error handling
3. **Testing**: Comprehensive unit test coverage
4. **Configuration**: Environment-specific settings

## 🔍 Troubleshooting

### Common Issues

#### Flutter Secure Storage on Linux
If you encounter `libsecret-1.so.0` errors on Linux:
```bash
sudo pacman -S libsecret  # Arch Linux
```

#### Build Runner Issues
If JSON serialization fails:
```bash
flutter clean
flutter pub get
dart run build_runner build
```

#### Database Migration Issues
If migrations fail:
```bash
cd backend
go run main.go  # This will run migrations automatically
```

## 📚 Additional Resources

- [Go Database/SQL Tutorial](https://golang.org/doc/database)
- [GORM Documentation](https://gorm.io/docs/)
- [Flutter SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

## 🎯 Next Steps

After completing this lab, you should be able to:
- Choose appropriate database patterns for different use cases
- Implement robust data persistence in Flutter applications
- Design clean data access layers using repository pattern
- Write comprehensive tests for data operations
- Handle database migrations and schema evolution 