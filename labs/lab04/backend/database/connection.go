package database

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

var (
	ErrCloseDB = errors.New("Error while closing DB")
)

// Config holds database configuration
type Config struct {
	DatabasePath    string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

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
	return InitDBWithConfig(DefaultConfig())
}

func InitDBWithConfig(cfg *Config) (*sql.DB, error) {
	if cfg == nil {
		return nil, fmt.Errorf("database config is nil")
	}

	db, err := sql.Open("sqlite3", cfg.DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("failed to open sqlite3 database: %w", err)
	}

	db.SetMaxOpenConns(cfg.MaxOpenConns)
	db.SetMaxIdleConns(cfg.MaxIdleConns)
	db.SetConnMaxLifetime(cfg.ConnMaxLifetime)
	db.SetConnMaxIdleTime(cfg.ConnMaxIdleTime)

	if err := db.Ping(); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("cannot ping database: %w", err)
	}

	return db, nil
}

func CloseDB(db *sql.DB) error {
	if db == nil {
		return ErrCloseDB
	}
	return db.Close()
}
