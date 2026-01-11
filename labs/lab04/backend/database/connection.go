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
	config := DefaultConfig()       // using default configuration via DefaultConfig()
	return InitDBWithConfig(config) // returns the database connection or an error, which is what the caller expects
}

func InitDBWithConfig(config *Config) (*sql.DB, error) {
	if config == nil {
		return nil, fmt.Errorf("invalid config value. Config cannot be nil")
	}
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to open database: %w", err)
	}
	// apply connection pull settingss
	db.SetMaxOpenConns(config.MaxOpenConns)       // sets the maximum number of open connections to the database
	db.SetMaxIdleConns(config.MaxIdleConns)       // sets the maximum number of idle(unused but open)
	db.SetConnMaxLifetime(config.ConnMaxLifetime) // limits the maximum lifetime of a single connection
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime) // sets how long a connection can remain idle before closed
	return db, nil
}

func CloseDB(db *sql.DB) error {
	if db != nil {
		return db.Close()
	}
	return fmt.Errorf("database is nil")
}
