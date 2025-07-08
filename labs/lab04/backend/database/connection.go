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

// TODO: Implement InitDB function
func InitDB() (*sql.DB, error) {
	// TODO: Initialize database connection with SQLite
	// - Open database connection using sqlite3 driver
	// - Apply connection pool configuration from DefaultConfig()
	// - Test connection with Ping()
	// - Return the database connection or error
	return nil, fmt.Errorf("TODO: implement InitDB function")
}

// TODO: Implement InitDBWithConfig function
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// TODO: Initialize database connection with custom configuration
	// - Open database connection using the provided config
	// - Apply all connection pool settings
	// - Test connection with Ping()
	// - Return the database connection or error
	return nil, fmt.Errorf("TODO: implement InitDBWithConfig function")
}

// TODO: Implement CloseDB function
func CloseDB(db *sql.DB) error {
	// TODO: Properly close database connection
	// - Check if db is not nil
	// - Close the database connection
	// - Return any error that occurs
	return fmt.Errorf("TODO: implement CloseDB function")
}
