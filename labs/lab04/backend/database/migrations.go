package database

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/pressly/goose/v3"
)

func GetMigrationsPath() string {
	cwd, err := os.Getwd() // returns the absolute path of the current working directory where our Go program is running
	if err != nil {
		return "labs/lab04/backend/migrations" // return relative part if Getwd() fails
	}
	idx := strings.Index(cwd, "backend")
	if idx != -1 {
		backendPath := cwd[:idx+len("backend")]
		return filepath.Join(backendPath, "migrations")
	}
	return filepath.Join(cwd, "migrations") // join current working directory with relative path
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
	migrationsDir := GetMigrationsPath()

	// Run migrations from the migrations directory
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := GetMigrationsPath()

	// Run migrations from the migrations directory
	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}
	return nil
}

func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Get path to migrations directory (relative to backend directory)
	migrationsDir := GetMigrationsPath()

	// Run migrations from the migrations directory
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}
	return nil
}

func CreateMigration(name string) error {
	// Get path to migrations directory (relative to backend directory)
	migrationsDir := GetMigrationsPath()

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Run migrations from the migrations directory
	if err := goose.Create(nil, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}
	return nil
}
