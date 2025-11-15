package database

import (
	"database/sql"
	"fmt"

	"github.com/pressly/goose/v3"
)

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
	migrationsDir := "../migrations"

	// Run migrations from the migrations directory
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	// Rollback migrations from the migrations directory
	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migrations: %v", err)
	}

	return nil
}

// Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	// Check collectMigrations
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migrations status: %w", err)
	}

	return nil
}

// Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if len(name) == 0 {
		return fmt.Errorf("migration name cannot be empty")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	if err := goose.Create(nil, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %w", err)
	}

	return nil
}
