package database

import (
	"database/sql"
	"errors"
	"fmt"
	"os"

	"github.com/pressly/goose/v3"
)

var migration_path = "../migrations"

// RunMigrations runs database migrations using goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Run migrations from the migrations directory
	if err := goose.Up(db, migration_path); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// TODO: Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection is nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect")
	}

	err = goose.Down(db, migration_path)
	if err != nil {
		return errors.New("failed to rollback migration")
	}
	return nil
}

// TODO: Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection is nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect")
	}

	err = goose.Status(db, migration_path)
	if err != nil {
		return errors.New("failed to get migration status")
	}
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}

	if _, err := os.Stat(migration_path); os.IsNotExist(err) {
		if err := os.Mkdir(migration_path, 0755); err != nil {
			return fmt.Errorf("failed to create migrations directory: %v", err)
		}
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	if err := goose.Create(nil, migration_path, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}

	return nil
}
