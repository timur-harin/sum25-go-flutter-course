package database

import (
	"database/sql"
	"fmt"
	"os"

	"github.com/pressly/goose/v3"
)

// getMigrationsPath returns the correct path to migrations directory
// This function works regardless of which directory the tests are run from
func getMigrationsPath() string {
	// Try different possible paths
	possiblePaths := []string{
		"./migrations",     // From backend directory
		"../migrations",    // From subdirectories
		"../../migrations", // From deeper subdirectories
		"migrations",       // From root
	}

	for _, path := range possiblePaths {
		if isDir(path) {
			return path
		}
	}

	// If no path found, return the most likely one
	return "./migrations"
}

// isDir checks if the given path is a directory
func isDir(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.IsDir()
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
	migrationsDir := getMigrationsPath()

	// Run migrations from the migrations directory
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// TODO: Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := getMigrationsPath()

	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migration: %v", err)
	}
	return nil
}

// TODO: Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := getMigrationsPath()

	err := goose.Status(db, migrationsDir)
	if err != nil {
		return fmt.Errorf("failed to get migration status: %v", err)
	}
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	// TODO: Use goose to create a new migration file with the given name\
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}
	migrationsDir := getMigrationsPath()

	err := goose.Create(nil, migrationsDir, name, "sql")
	if err != nil {
		return fmt.Errorf("failed to create migration: %w", err)
	}
	return nil
}
