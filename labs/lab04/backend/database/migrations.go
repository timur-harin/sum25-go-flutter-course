package database

import (
	"database/sql"
	"fmt"

	"github.com/pressly/goose/v3"
)

func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("nil database connection detected")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return fmt.Errorf("error setting dialect: %v", err)
	}
	migrationPath := "../migrations"
	if upErr := goose.Up(db, migrationPath); upErr != nil {
		return fmt.Errorf("migration execution failed: %v", upErr)
	}
	return nil
}

func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection is nil")
	}
	if dialectErr := goose.SetDialect("sqlite3"); dialectErr != nil {
		return fmt.Errorf("dialect setting error: %v", dialectErr)
	}
	migrationPath := "../migrations"
	if downErr := goose.Down(db, migrationPath); downErr != nil {
		return fmt.Errorf("rollback failed: %v", downErr)
	}
	return nil
}

func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("nil database connection provided")
	}
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to configure dialect: %v", err)
	}
	migrationPath := "../migrations"
	if statusErr := goose.Status(db, migrationPath); statusErr != nil {
		return fmt.Errorf("migration status check failed: %v", statusErr)
	}
	return nil
}

func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name must not be empty")
	}
	migrationPath := "../migrations"
	err := goose.Create(nil, migrationPath, name, "sql")
	if err != nil {
		return fmt.Errorf("error creating migration: %v", err)
	}
	return nil
}