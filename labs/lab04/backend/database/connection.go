package database

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// Config holds database configuration parameters
type Config struct {
	DatabasePath    string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

// DefaultConfig returns the default configuration for the database connection
func DefaultConfig() *Config {
	cfg := new(Config)
	cfg.DatabasePath = "./lab04.db"
	cfg.MaxOpenConns = 25
	cfg.MaxIdleConns = 5
	cfg.ConnMaxLifetime = time.Minute * 5
	cfg.ConnMaxIdleTime = time.Minute * 2
	return cfg
}

// InitDB initializes the database connection using the default configuration
func InitDB() (*sql.DB, error) {
	defCfg := DefaultConfig()
	return InitDBWithConfig(defCfg)
}

// InitDBWithConfig initializes the database connection using the given configuration
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	database, openErr := sql.Open("sqlite3", config.DatabasePath)
	if openErr != nil {
		return nil, openErr
	}

	// Set connection pool parameters in a different order
	database.SetConnMaxIdleTime(config.ConnMaxIdleTime)
	database.SetConnMaxLifetime(config.ConnMaxLifetime)
	database.SetMaxIdleConns(config.MaxIdleConns)
	database.SetMaxOpenConns(config.MaxOpenConns)

	// Check database connectivity
	pingErr := database.Ping()
	if pingErr != nil {
		return nil, pingErr
	}

	return database, nil
}

// CloseDB closes the database connection if it is not nil
func CloseDB(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("cannot close a nil database connection")
	}
	return db.Close()
}