package database

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/pressly/goose/v3"
)

// getMigrationsDir returns the absolute path to labs/lab04/backend/migrations
func getMigrationsDir() string {
	cwd, err := os.Getwd()
	if err != nil {
		return "labs/lab04/backend/migrations"
	}
	// Найти путь до backend
	idx := strings.Index(cwd, "backend")
	if idx != -1 {
		backendPath := cwd[:idx+len("backend")]
		return filepath.Join(backendPath, "migrations")
	}
	// Fallback: относительный путь
	return "labs/lab04/backend/migrations"
}

// RunMigrations runs database migrations using goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := getMigrationsDir()

	// Run migrations from the migrations directory
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := getMigrationsDir()

	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migration: %v", err)
	}

	return nil
}

// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := getMigrationsDir()

	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migration status: %v", err)
	}

	return nil
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	migrationsDir := getMigrationsDir()

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	if err := goose.Create(nil, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}

	return nil
}
