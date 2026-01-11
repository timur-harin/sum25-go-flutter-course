package database

import (
	"database/sql"
	"errors"
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

// Implement InitDB function
func InitDB() (*sql.DB, error) {
	// Initialize database connection with SQLite
	// - Open database connection using sqlite3 driver
	// - Apply connection pool configuration from DefaultConfig()
	// - Test connection with Ping()
	// - Return the database connection or error
	return InitDBWithConfig(DefaultConfig())
}

// Implement InitDBWithConfig function
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// Initialize database connection with custom configuration
	// - Open database connection using the provided config
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, err
	}
	// - Apply all connection pool settings
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)
	// - Test connection with Ping()
	if err := db.Ping(); err != nil {
		return nil, err
	}
	// - Return the database connection or error
	return db, nil
}

// Implement CloseDB function
func CloseDB(db *sql.DB) error {
	// Properly close database connection
	// - Check if db is not nil
	if db == nil {
		return errors.New("error: db is nil")
	}
	// - Close the database connection
	if err := db.Close(); err == nil {
		return err
	}
	// - Return any error that occurs
	return nil
}
