package database

import (
	"database/sql"
	"fmt"
	"os"

	"github.com/pressly/goose/v3"
)

// RunMigrations runs database migrations using goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %w", err)
	}

	migrationsDir := "../migrations"

	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	return nil
}

// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %w", err)
	}

	migrationsDir := "../migrations"

	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migration: %w", err)
	}

	return nil
}

// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %w", err)
	}

	migrationsDir := "../migrations"

	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migration status: %w", err)
	}

	return nil
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}

	migrationsDir := "../migrations"

	// Ensure the migrations directory exists
	if err := os.MkdirAll(migrationsDir, os.ModePerm); err != nil {
		return fmt.Errorf("failed to create migrations directory: %w", err)
	}

	if err := goose.Create(nil, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %w", err)
	}

	return nil
}
