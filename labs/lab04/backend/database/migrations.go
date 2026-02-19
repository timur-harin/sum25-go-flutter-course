package database

import (
	"database/sql"
	"fmt"
	"os"
	"os/exec"

	"github.com/pressly/goose/v3"
)

// RunMigrations запускает миграции базы данных с помощью goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Устанавливаем диалект goose для SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	// Путь к директории миграций (относительно backend)
	migrationsDir := "../migrations"

	// Запускаем миграции из директории миграций
	if err := goose.Up(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// RollbackMigration откатывает последнюю миграцию с помощью goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := "../migrations"

	// Откатываем одну миграцию назад
	if err := goose.Down(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to rollback migration: %v", err)
	}

	return nil
}

// GetMigrationStatus проверяет статус миграций с помощью goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	migrationsDir := "../migrations"

	// Получаем статус миграций
	if err := goose.Status(db, migrationsDir); err != nil {
		return fmt.Errorf("failed to get migration status: %v", err)
	}

	fmt.Println("Статус миграций получен успешно")

	return nil
}

// CreateMigration создает новый файл миграции с помощью goose
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("имя миграции не может быть пустым")
	}

	migrationsDir := "../migrations"

	// Проверяем, существует ли директория миграций
	if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
		if err := os.MkdirAll(migrationsDir, 0755); err != nil {
			return fmt.Errorf("не удалось создать директорию миграций: %v", err)
		}
	}

	// Используем goose для создания миграции через команду
	cmd := exec.Command("goose", "-dir", migrationsDir, "create", name, "sql")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("не удалось создать миграцию: %v", err)
	}

	return nil
}
