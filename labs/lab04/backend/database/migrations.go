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
	if err := goose.SetDialect("sqlite"); err != nil {
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
		return fmt.Errorf("database connection cannot be nil")
	}
	if err := goose.SetDialect("sqlite"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}
	migrationsDir := "../migrations"
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
	if err := goose.SetDialect("sqlite"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}
	migrationsDir := "../migrations"
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migration status: %v", err)
	}
	return nil
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	migrationsDir := "../migrations"
	if err := goose.Create(nil, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}
	return nil
}
