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

// InitDB initializes a database connection using the default configuration.
func InitDB() (*sql.DB, error) {
	return InitDBWithConfig(DefaultConfig())
}

// InitDBWithConfig initializes a database connection using a custom configuration.
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	if config == nil {
		return nil, fmt.Errorf("InitDBWithConfig: config is nil")
	}

	// Open SQLite connection. Extra pragmas improve safety & concurrency.
	dsn := fmt.Sprintf("%s?_busy_timeout=10000&_foreign_keys=on", config.DatabasePath)
	db, err := sql.Open("sqlite3", dsn)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %w", err)
	}

	// Connection-pool settings
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	// Verify the connection
	if err := db.Ping(); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("db.Ping: %w", err)
	}

	return db, nil
}

// CloseDB properly closes the database connection.
func CloseDB(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("CloseDB: db is nil")
	}
	return db.Close()
}
