package database

import (
	"database/sql"
	"fmt"
	"path/filepath"
	"runtime"

	"github.com/pressly/goose/v3"
)

func migrationsDir() (string, error) {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		return "", fmt.Errorf("unable to determine caller path")
	}
	return filepath.Join(filepath.Dir(file), "..", "migrations"), nil
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

	dir, err := migrationsDir()
	if err != nil {
		return err
	}

	// Run migrations from the migrations directory
	if err := goose.Up(db, dir); err != nil {
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
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}
	dir, err := migrationsDir()
	if err != nil {
		return err
	}
	if err := goose.Down(db, dir); err != nil {
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
	dir, err := migrationsDir()
	if err != nil {
		return err
	}
	if err := goose.Status(db, dir); err != nil {
		return fmt.Errorf("failed to get migration status: %v", err)
	}
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}
	dir, err := migrationsDir()
	if err != nil {
		return err
	}
	if err := goose.Create(nil, dir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}
	return nil
}
