# Lab 04 Backend - Database & Persistence

Go backend demonstrating multiple database approaches and migration management.

## 🛠️ Migration Commands

### Quick Start
```bash
# Setup fresh database
make setup-db

# Install dependencies
make tidy
```

### Migration Management
```bash
# Run all pending migrations
make migrate-up

# Rollback last migration  
make migrate-down

# Check migration status
make migrate-status

# Create new migration
make migrate-create NAME=add_new_feature

# Reset database (⚠️ removes all data)
make migrate-reset
```

### Development Commands
```bash
# Show all available commands
make help

# Run tests
make test

# Run tests with coverage
make test-coverage

# Database inspection
make show-schema    # Show full schema
make show-tables    # List all tables

# Database management
make clean-db       # Remove database file
make backup-db      # Create timestamped backup
```

## 📁 Migration Files

Migrations are stored in `../migrations/` directory:
- `20250708090008_create_users_table.sql`
- `20250708090034_create_posts_table.sql` 
- `20250708090055_create_categories_table.sql`

## 🎯 Task Structure

### ✅ NECESSARY Tasks (Required)
1. **Data Models** (`models/user.go`, `models/post.go`)
2. **Database Infrastructure** (`database/connection.go`, `database/migrations.go`)
3. **Manual SQL Repository** (`repository/user_repository.go`)

### 🟡 OPTIONAL Tasks (Advanced Learning)
4. **Scany Mapping** (`repository/post_repository.go`)
5. **Squirrel Builder** (`services/search_service.go`)
6. **GORM ORM** (`repository/category_repository.go`)

## 🗄️ Database Schema

The migrations create these tables:
- **users**: User accounts with soft delete support
- **posts**: Blog posts with user relationships
- **categories**: Category system for GORM examples
- **post_categories**: Many-to-many junction table

All tables include proper indexes for performance and foreign key constraints for data integrity.

## 🚀 Next Steps

1. Complete the 3 necessary tasks first
2. Run tests: `make test-with-fresh-db`
3. Explore optional approaches based on interest
4. Study different database patterns and trade-offs 