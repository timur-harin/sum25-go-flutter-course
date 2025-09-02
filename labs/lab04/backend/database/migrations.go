package database

import (
	"database/sql"
	"fmt"
	"os"
	"os/exec"

	"github.com/pressly/goose/v3"
)

// Get path to migrations directory (relative to backend directory)
var migrationsDir = "../migrations"

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

	if err := goose.SetDialect("sqlite3"); err != nil {
		return err
	}

	return goose.Down(db, migrationsDir)
}

// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return err
	}

	return goose.Status(db, migrationsDir)
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}

	cmd := exec.Command("goose", "-dir", migrationsDir, "create", name, "sql")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}

	return nil
}
