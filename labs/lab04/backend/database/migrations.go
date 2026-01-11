package database

import (
	"database/sql"
	"fmt"

	"github.com/pressly/goose/v3"
)

const migrationsDir = "../migrations"

// RunMigrations runs database migrations using goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %w", err)
	}

	// Run all up migrations
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
	// Down by 1 step (rollback last)
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
	// Prints status table to stdout
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migration status: %w", err)
	}
	return nil
}

// CreateMigration creates a new migration file
// name should be a short descriptive name, e.g. "create_users_table"
func CreateMigration(db *sql.DB, name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}
	// обязательно установить диалект
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %w", err)
	}
	// теперь db, папка, имя и расширение
	if err := goose.Create(db, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration %q: %w", name, err)
	}
	return nil
}
