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
		return ErrNilDB
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
		return ErrNilDB
	}
	
	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migrations: %v", err)
	}
	
	return nil
}

// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return ErrNilDB
	}
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to check migration status: %v", err)
	}
	return nil
}

// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	db, err := InitDB()
	if err != nil { return err }
	if err := goose.Create(db, migrationsDir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration %v: %v", name, err)
	}
	return CloseDB(db)
}
