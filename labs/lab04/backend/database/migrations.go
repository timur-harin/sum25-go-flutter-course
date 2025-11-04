package database

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

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

	// Get path to migrations directory
	migrationsDir := "./migrations"
	if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
		// Try from parent directory (for tests running from subdirectories)
		migrationsDir = "../migrations"
		if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
			// Try relative to current working directory
			wd, _ := os.Getwd()
			migrationsDir = filepath.Join(wd, "migrations")
			if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
				return fmt.Errorf("migrations directory not found")
			}
		}
	}

	// Run migrations from the migrations directory
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// TODO: Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	return nil
}

// TODO: Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	return nil
}
