package database

import (
	"database/sql"
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

// InitDB initializes a database connection using the default configuration
func InitDB() (*sql.DB, error) {
	// Get default configuration
	config := DefaultConfig()

	// Open database connection using sqlite3 driver
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		// Return error if connection could not be opened
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Apply connection pool configuration
	db.SetMaxOpenConns(config.MaxOpenConns)       // Set maximum number of open connections
	db.SetMaxIdleConns(config.MaxIdleConns)       // Set maximum number of idle connections
	db.SetConnMaxLifetime(config.ConnMaxLifetime) // Set maximum connection lifetime
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime) // Set maximum idle time for a connection

	// Test connection with Ping()
	if err := db.Ping(); err != nil {
		// Close db if ping fails
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	// Return the database connection
	return db, nil
}

// InitDBWithConfig initializes a database connection using a custom configuration
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// Open database connection using sqlite3 driver and provided config
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		// Return error if connection could not be opened
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Apply all connection pool settings
	db.SetMaxOpenConns(config.MaxOpenConns)       // Set maximum number of open connections
	db.SetMaxIdleConns(config.MaxIdleConns)       // Set maximum number of idle connections
	db.SetConnMaxLifetime(config.ConnMaxLifetime) // Set maximum connection lifetime
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime) // Set maximum idle time for a connection

	// Test connection with Ping()
	if err := db.Ping(); err != nil {
		// Close db if ping fails
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	// Return the database connection
	return db, nil
}

// CloseDB properly closes the database connection
func CloseDB(db *sql.DB) error {
	// Check if db is not nil
	if db == nil {
		// Return error if db is nil
		return fmt.Errorf("database connection is nil")
	}
	// Close the database connection
	return db.Close()
}
