package database

import (
	"database/sql"
	"errors"
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

// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return errors.New("nil database provided: RollbackMigration()")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	// Rollback to the last migration
	return goose.Down(db, migrationsDir)
}

// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return errors.New("nil database provided: GetMigrationStatus()")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	// Print the migration status
	return goose.Status(db, migrationsDir)
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := "../migrations"

	// Create the .sql migration file
	return goose.Create(nil, migrationsDir, name, "sql")
}
