package database

import (
	"os"
	"testing"
	"time"
)

func TestDefaultConfig(t *testing.T) {
	config := DefaultConfig()

	if config == nil {
		t.Fatal("DefaultConfig() returned nil")
	}

	if config.DatabasePath == "" {
		t.Error("DefaultConfig() DatabasePath should not be empty")
	}

	if config.MaxOpenConns <= 0 {
		t.Error("DefaultConfig() MaxOpenConns should be positive")
	}

	if config.MaxIdleConns <= 0 {
		t.Error("DefaultConfig() MaxIdleConns should be positive")
	}

	if config.ConnMaxLifetime <= 0 {
		t.Error("DefaultConfig() ConnMaxLifetime should be positive")
	}

	if config.ConnMaxIdleTime <= 0 {
		t.Error("DefaultConfig() ConnMaxIdleTime should be positive")
	}
}

func TestInitDB(t *testing.T) {
	// Clean up test database before and after
	testDB := "./test_init.db"
	defer os.Remove(testDB)
	os.Remove(testDB)

	// Test with default config
	db, err := InitDB()
	if err != nil {
		t.Fatalf("InitDB() failed: %v", err)
	}

	if db == nil {
		t.Fatal("InitDB() returned nil database")
	}

	// Test that we can ping the database
	if err := db.Ping(); err != nil {
		t.Errorf("Database ping failed: %v", err)
	}

	// Clean up
	if err := CloseDB(db); err != nil {
		t.Errorf("CloseDB() failed: %v", err)
	}
}

func TestInitDBWithConfig(t *testing.T) {
	// Clean up test database before and after
	testDB := "./test_config.db"
	defer os.Remove(testDB)
	os.Remove(testDB)

	// Create custom config
	config := &Config{
		DatabasePath:    testDB,
		MaxOpenConns:    10,
		MaxIdleConns:    2,
		ConnMaxLifetime: 2 * time.Minute,
		ConnMaxIdleTime: 1 * time.Minute,
	}

	db, err := InitDBWithConfig(config)
	if err != nil {
		t.Fatalf("InitDBWithConfig() failed: %v", err)
	}

	if db == nil {
		t.Fatal("InitDBWithConfig() returned nil database")
	}

	// Test that we can ping the database
	if err := db.Ping(); err != nil {
		t.Errorf("Database ping failed: %v", err)
	}

	// Clean up
	if err := CloseDB(db); err != nil {
		t.Errorf("CloseDB() failed: %v", err)
	}
}

func TestMigrate(t *testing.T) {
	// Clean up test database before and after
	testDB := "./test_migrate.db"
	defer os.Remove(testDB)
	os.Remove(testDB)

	config := &Config{
		DatabasePath:    testDB,
		MaxOpenConns:    5,
		MaxIdleConns:    1,
		ConnMaxLifetime: 1 * time.Minute,
		ConnMaxIdleTime: 30 * time.Second,
	}

	db, err := InitDBWithConfig(config)
	if err != nil {
		t.Fatalf("InitDBWithConfig() failed: %v", err)
	}
	defer CloseDB(db)

	// Test migration
	err = RunMigrations(db)
	if err != nil {
		t.Fatalf("RunMigrations() failed: %v", err)
	}

	// Test that tables were created by checking if we can query them
	_, err = db.Exec("SELECT COUNT(*) FROM users")
	if err != nil {
		t.Errorf("Users table not created properly: %v", err)
	}

	_, err = db.Exec("SELECT COUNT(*) FROM posts")
	if err != nil {
		t.Errorf("Posts table not created properly: %v", err)
	}

	// Test that we can insert data (basic schema validation)
	_, err = db.Exec(`
		INSERT INTO users (name, email, created_at, updated_at) 
		VALUES ('Test User', 'test@example.com', datetime('now'), datetime('now'))
	`)
	if err != nil {
		t.Errorf("Cannot insert into users table: %v", err)
	}

	// Get the user ID for the post test
	var userID int
	err = db.QueryRow("SELECT id FROM users WHERE email = 'test@example.com'").Scan(&userID)
	if err != nil {
		t.Errorf("Cannot query user: %v", err)
	}

	_, err = db.Exec(`
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES (?, 'Test Post', 'Test content', 1, datetime('now'), datetime('now'))
	`, userID)
	if err != nil {
		t.Errorf("Cannot insert into posts table: %v", err)
	}
}

func TestCloseDB(t *testing.T) {
	// Test closing nil database
	err := CloseDB(nil)
	if err == nil {
		t.Error("CloseDB(nil) should return an error")
	}

	// Test closing valid database
	testDB := "./test_close.db"
	defer os.Remove(testDB)
	os.Remove(testDB)

	config := &Config{
		DatabasePath:    testDB,
		MaxOpenConns:    5,
		MaxIdleConns:    1,
		ConnMaxLifetime: 1 * time.Minute,
		ConnMaxIdleTime: 30 * time.Second,
	}

	db, err := InitDBWithConfig(config)
	if err != nil {
		t.Fatalf("InitDBWithConfig() failed: %v", err)
	}

	err = CloseDB(db)
	if err != nil {
		t.Errorf("CloseDB() failed: %v", err)
	}

	// Test that database is actually closed
	err = db.Ping()
	if err == nil {
		t.Error("Database should be closed and ping should fail")
	}
}
