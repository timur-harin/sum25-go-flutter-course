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

// TODO: Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection cannot be nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect: " + err.Error())
	}
	migrationsDir := "../migrations"
	if err := goose.Down(db, migrationsDir); err != nil {
		return errors.New("failed to rollback migration: " + err.Error())
	}
	return nil
}

// TODO: Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection cannot be nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect: " + err.Error())
	}
	migrationsDir := "../migrations"
	err = goose.Status(db, migrationsDir)
	if err != nil {
		return errors.New("failed to get migration status: " + err.Error())
	}
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return errors.New("migration name cannot be empty")
	}
	db, err := sql.Open("sqlite3", "./mydb.sqlite")
	if err != nil {
		return fmt.Errorf("failed to open database: %v", err)
	}
	defer db.Close()

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := "../migrations"
	if err := goose.Create(db, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}
	return nil
}
