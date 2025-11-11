package database

import (
	"database/sql"
	"errors"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

var (
	ErrNilDB = errors.New("DB is nil")
)

const (
	DBPath = "../lab04.db"
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
		DatabasePath:    DBPath,
		MaxOpenConns:    25,
		MaxIdleConns:    5,
		ConnMaxLifetime: 5 * time.Minute,
		ConnMaxIdleTime: 2 * time.Minute,
	}
}

func (c Config) Use(db *sql.DB) {
	db.SetMaxIdleConns(c.MaxIdleConns)
	db.SetMaxOpenConns(c.MaxOpenConns)
	db.SetConnMaxIdleTime(c.ConnMaxIdleTime)
	db.SetConnMaxLifetime(c.ConnMaxLifetime)
}

func InitDB() (*sql.DB, error) {
	config := DefaultConfig()
	db, err := sql.Open("sqlite3", config.DatabasePath)
	
	if err != nil {
		return nil, err
	}
	
	config.Use(db)
	
	err = db.Ping()
	
	if err != nil {
		return nil, err
	}
	
	return db, nil
}

func InitDBWithConfig(config *Config) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", config.DatabasePath)
	
	if err != nil {
		return nil, err
	}
	
	config.Use(db)
	
	err = db.Ping()
	
	if err != nil {
		return nil, err
	}
	
	return db, nil
}

func CloseDB(db *sql.DB) error {
	if db == nil {
		return ErrNilDB
	}
	return db.Close()
}