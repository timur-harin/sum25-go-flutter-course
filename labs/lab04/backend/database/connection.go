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

func InitDB() (*sql.DB, error) {
	// - Open database connection using sqlite3 driver
	config := DefaultConfig()

	// Open database connection using sqlite3 driver
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("DB: connection failed: %w", err)
	}

	// - Apply connection pool configuration from DefaultConfig()
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	// - Test connection with Ping()
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("DB: ping failed: %w", err)
	}

	// - Return the database connection or error
	return db, nil
}

// TODO: Implement InitDBWithConfig function
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// Open database connection using sqlite3 driver
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("DB: connection failed: %w", err)
	}

	// - Apply connection pool configuration from DefaultConfig()
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	// - Test connection with Ping()
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("DB: ping failed: %w", err)
	}

	// - Return the database connection or error
	return db, nil
}

// TODO: Implement CloseDB function
func CloseDB(db *sql.DB) error {
	// - Check if db is not nil
	if db == nil {
		return fmt.Errorf("DB connection cannot be nil")
	}
	// - Close the database connection
	return db.Close()
}
