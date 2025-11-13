package database

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// Config holds database configuration
type Config struct {
	DatabasePath    string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

// DefaultConfig returns a default database configuration
func DefaultConfig() *Config {
	return &Config{
		DatabasePath:    "./lab04.db",
		MaxOpenConns:    25,
		MaxIdleConns:    5,
		ConnMaxLifetime: 5 * time.Minute,
		ConnMaxIdleTime: 2 * time.Minute,
	}
}

// TODO: Implement InitDB function
func InitDB() (*sql.DB, error) {
	// TODO: Initialize database connection with SQLite
	// - Open database connection using sqlite3 driver
	// - Apply connection pool configuration from DefaultConfig()
	// - Test connection with Ping()
	// - Return the database connection or error
	db, err := sql.Open("sqlite3", DefaultConfig().DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}
	db.SetMaxOpenConns(DefaultConfig().MaxOpenConns)
	db.SetMaxIdleConns(DefaultConfig().MaxIdleConns)
	db.SetConnMaxLifetime(DefaultConfig().ConnMaxLifetime)
	db.SetConnMaxIdleTime(DefaultConfig().ConnMaxIdleTime)
	if err := db.Ping(); err != nil {
		return nil, errors.New("failed to ping database: " + err.Error())
	}
	return db, nil
}

// TODO: Implement InitDBWithConfig function
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// TODO: Initialize database connection with custom configuration
	// - Open database connection using the provided config
	// - Apply all connection pool settings
	// - Test connection with Ping()
	// - Return the database connection or error
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, errors.New("failed to open database: " + err.Error())
	}
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)
	if err := db.Ping(); err != nil {
		return nil, errors.New("failed to ping database: " + err.Error())
	}
	return db, nil
}

// TODO: Implement CloseDB function
func CloseDB(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection is nil")
	}
	if err := db.Close(); err != nil {
		return errors.New("failed to close database: " + err.Error())
	}
	return nil
}
