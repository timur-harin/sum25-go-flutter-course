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

// InitDB инициализирует соединение с базой данных SQLite с настройками по умолчанию
func InitDB() (*sql.DB, error) {
	config := DefaultConfig()
	return InitDBWithConfig(config)
}

// InitDBWithConfig инициализирует соединение с базой данных SQLite с кастомной конфигурацией
func InitDBWithConfig(config *Config) (*sql.DB, error) {
	if config == nil {
		return nil, fmt.Errorf("InitDBWithConfig: config не может быть nil")
	}
	db, err := sql.Open("sqlite3", config.DatabasePath)
	if err != nil {
		return nil, fmt.Errorf("ошибка открытия базы данных: %w", err)
	}

	// Применяем настройки пула соединений
	db.SetMaxOpenConns(config.MaxOpenConns)
	db.SetMaxIdleConns(config.MaxIdleConns)
	db.SetConnMaxLifetime(config.ConnMaxLifetime)
	db.SetConnMaxIdleTime(config.ConnMaxIdleTime)

	// Проверяем соединение
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("ошибка соединения с базой данных: %w", err)
	}

	return db, nil
}

// CloseDB корректно закрывает соединение с базой данных
func CloseDB(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("CloseDB: db не может быть nil")
	}
	return db.Close()
}
