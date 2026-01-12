package database

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// Config holds configuration for the DB connection
type Config struct {
	DatabasePath    string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

// DefaultConfig returns sane defaults for SQLite DB
func DefaultConfig() *Config {
	return &Config{
		DatabasePath:    "lab04.db",
		MaxOpenConns:    1, // SQLite doesn't support concurrency well
		MaxIdleConns:    1,
		ConnMaxLifetime: time.Hour,
		ConnMaxIdleTime: time.Minute,
	}
}

func InitDB() (*sql.DB, error) {
	return InitDBWithConfig(DefaultConfig())
}

func InitDBWithConfig(config *Config) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}

func CloseDB(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("cannot close nil database")
	}
	return db.Close()
}
