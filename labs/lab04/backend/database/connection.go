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
	// Database is stored in the lab04.db file
	// It allows for 25 connections being opened simultaniously
	// Only 5 connections can be idle simultaniously
	// Maximum time for a connection being opened: 5 min
	// Maximum time for an idle connection being opened: 2 min
	return &Config{
		DatabasePath:    "./lab04.db",
		MaxOpenConns:    25,
		MaxIdleConns:    5,
		ConnMaxLifetime: 5 * time.Minute,
		ConnMaxIdleTime: 2 * time.Minute,
	}
}

// Initializes a database on the local machine according to default config
func InitDB() (*sql.DB, error) {
	// Get the default configuration
	defaultCfg := DefaultConfig()
	// Initialize the database according to the config
	return InitDBWithConfig(defaultCfg)
}

// Initializes a database on the local machine
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	// Open a connection using sqlite3 driver and the path to the database
	connPtr, openErr := sql.Open("sqlite3", config.DatabasePath)
	if openErr != nil {
		// Do not change anything, just throw the result
		return connPtr, openErr
	}

	// Configure the connection
	connPtr.SetMaxOpenConns(config.MaxOpenConns)
	connPtr.SetMaxIdleConns(config.MaxIdleConns)
	connPtr.SetConnMaxLifetime(config.ConnMaxLifetime)
	connPtr.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	// Check if the database responds to an incoming connection
	pingErr := connPtr.Ping()
	if pingErr != nil {
		return nil, pingErr
	}

	// OK -> return the connection
	return connPtr, nil
}

// TODO: Implement CloseDB function
func CloseDB(db *sql.DB) error {
	// Check if the database is nil
	if db == nil {
		return errors.New("nil database connection provided: CloseDB")
	}

	// Close the connection
	db.Close()

	return nil // OK - no error
}
