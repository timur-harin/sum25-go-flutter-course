package database

import (
    "database/sql"
    "errors"
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

// InitDB opens a SQLite database using the DefaultConfig settings.
func InitDB() (*sql.DB, error) {
    return InitDBWithConfig(DefaultConfig())
}

// InitDBWithConfig opens a SQLite database using custom settings.
func InitDBWithConfig(config *Config) (*sql.DB, error) {
    if config == nil {
        return nil, errors.New("database config cannot be nil")
    }

    // enable foreign keys explicitly
    dsn := fmt.Sprintf("file:%s?_foreign_keys=on", config.DatabasePath)

    db, err := sql.Open("sqlite3", dsn)
    if err != nil {
        return nil, err
    }

    // apply pool settings
    db.SetMaxOpenConns(config.MaxOpenConns)
    db.SetMaxIdleConns(config.MaxIdleConns)
    db.SetConnMaxLifetime(config.ConnMaxLifetime)
    db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

    // verify the connection works
    if err := db.Ping(); err != nil {
        _ = db.Close()
        return nil, err
    }

    return db, nil
}

// CloseDB closes the given sql.DB instance.
func CloseDB(db *sql.DB) error {
    if db == nil {
        return errors.New("database handle is nil")
    }
    return db.Close()
}