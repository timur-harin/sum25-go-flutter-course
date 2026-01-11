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
	config := DefaultConfig()
	return InitDBWithConfig(config)
}

func InitDBWithConfig(config *Config) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, err
	}

	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetMaxOpenConns(config.MaxOpenConns)

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}

func CloseDB(db *sql.DB) error {
	if db != nil {
		err := db.Close()
		if err != nil {
			return err
		}
		return nil
	}
	return fmt.Errorf("Database is nil")
}
