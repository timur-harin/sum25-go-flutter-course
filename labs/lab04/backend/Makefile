# Go database migration management with goose
# Usage: make migrate-up, make migrate-down, make migrate-status, etc.

# Database configuration
DATABASE_URL ?= ./lab04.db
MIGRATIONS_DIR = ./migrations

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make migrate-up       - Run all pending migrations"
	@echo "  make migrate-down     - Rollback last migration"
	@echo "  make migrate-status   - Show migration status"
	@echo "  make migrate-reset    - Reset database (DROP ALL TABLES)"
	@echo "  make migrate-create   - Create new migration (usage: make migrate-create NAME=add_new_table)"
	@echo "  make install-goose    - Install goose migration tool"
	@echo "  make clean-db         - Remove database file"
	@echo "  make setup-db         - Clean and setup fresh database"

# Install goose if not present
.PHONY: install-goose
install-goose:
	@which goose > /dev/null || go install github.com/pressly/goose/v3/cmd/goose@latest
	@echo "✅ Goose migration tool ready"

# Run all pending migrations
.PHONY: migrate-up
migrate-up: install-goose
	@echo "🚀 Running migrations..."
	@goose -dir $(MIGRATIONS_DIR) sqlite3 $(DATABASE_URL) up
	@echo "✅ Migrations completed"

# Rollback last migration
.PHONY: migrate-down
migrate-down: install-goose
	@echo "⏪ Rolling back last migration..."
	@goose -dir $(MIGRATIONS_DIR) sqlite3 $(DATABASE_URL) down
	@echo "✅ Rollback completed"

# Show migration status
.PHONY: migrate-status
migrate-status: install-goose
	@echo "📊 Migration status:"
	@goose -dir $(MIGRATIONS_DIR) sqlite3 $(DATABASE_URL) status

# Reset database (WARNING: removes all data)
.PHONY: migrate-reset
migrate-reset: install-goose
	@echo "⚠️  WARNING: This will remove ALL data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@goose -dir $(MIGRATIONS_DIR) sqlite3 $(DATABASE_URL) reset
	@echo "🗑️  Database reset completed"

# Create new migration
.PHONY: migrate-create
migrate-create: install-goose
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Error: NAME is required. Usage: make migrate-create NAME=add_new_table"; \
		exit 1; \
	fi
	@echo "📝 Creating migration: $(NAME)"
	@goose -dir $(MIGRATIONS_DIR) create $(NAME) sql
	@echo "✅ Migration created in $(MIGRATIONS_DIR)/"

# Remove database file
.PHONY: clean-db
clean-db:
	@echo "🗑️  Removing database file..."
	@rm -f $(DATABASE_URL)
	@echo "✅ Database file removed"

# Setup fresh database
.PHONY: setup-db
setup-db: clean-db migrate-up
	@echo "🎉 Fresh database setup completed!"

# Run tests with fresh database
.PHONY: test-with-fresh-db
test-with-fresh-db: setup-db
	@echo "🧪 Running tests with fresh database..."
	@go test ./...

# Show database schema (requires sqlite3 command)
.PHONY: show-schema
show-schema:
	@echo "📋 Database schema:"
	@sqlite3 $(DATABASE_URL) ".schema"

# Show all tables
.PHONY: show-tables
show-tables:
	@echo "📊 Database tables:"
	@sqlite3 $(DATABASE_URL) ".tables"

# Backup database
.PHONY: backup-db
backup-db:
	@echo "💾 Creating database backup..."
	@cp $(DATABASE_URL) "./lab04_backup_$(shell date +%Y%m%d_%H%M%S).db"
	@echo "✅ Backup created"

# Development helpers
.PHONY: dev-setup
dev-setup: install-goose setup-db
	@echo "👨‍💻 Development environment setup completed!"
	@echo "📚 Next steps:"
	@echo "  - Run 'make test-with-fresh-db' to verify setup"
	@echo "  - Use 'make migrate-create NAME=your_migration' to add migrations"
	@echo "  - Use 'make migrate-status' to check migration state"

# Run go mod tidy
.PHONY: tidy
tidy:
	@echo "🧹 Running go mod tidy..."
	@go mod tidy
	@echo "✅ Dependencies updated"

# Run all tests
.PHONY: test
test:
	@echo "🧪 Running all tests..."
	@go test ./... -v

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "📊 Running tests with coverage..."
	@go test ./... -cover -coverprofile=coverage.out
	@go tool cover -html=coverage.out -o coverage.html
	@echo "✅ Coverage report generated: coverage.html" 