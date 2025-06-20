package config

import (
	"os"
	"testing"
)

func TestLoad(t *testing.T) {
	// Test default values
	cfg := Load()

	if cfg.Env != "development" {
		t.Errorf("Expected default env to be 'development', got '%s'", cfg.Env)
	}

	if cfg.Port != "8080" {
		t.Errorf("Expected default port to be '8080', got '%s'", cfg.Port)
	}

	if cfg.JWTSecret != "your-jwt-secret-key" {
		t.Errorf("Expected default JWT secret to be 'your-jwt-secret-key', got '%s'", cfg.JWTSecret)
	}
}

func TestLoadWithEnvVars(t *testing.T) {
	// Set environment variables
	os.Setenv("ENV", "test")
	os.Setenv("PORT", "9000")
	os.Setenv("JWT_SECRET", "test-secret")

	// Clean up after test
	defer func() {
		os.Unsetenv("ENV")
		os.Unsetenv("PORT")
		os.Unsetenv("JWT_SECRET")
	}()

	cfg := Load()

	if cfg.Env != "test" {
		t.Errorf("Expected env to be 'test', got '%s'", cfg.Env)
	}

	if cfg.Port != "9000" {
		t.Errorf("Expected port to be '9000', got '%s'", cfg.Port)
	}

	if cfg.JWTSecret != "test-secret" {
		t.Errorf("Expected JWT secret to be 'test-secret', got '%s'", cfg.JWTSecret)
	}
}

func TestGetEnvAsInt(t *testing.T) {
	// Test with valid integer
	os.Setenv("TEST_INT", "42")
	defer os.Unsetenv("TEST_INT")

	result := getEnvAsInt("TEST_INT", 10)
	if result != 42 {
		t.Errorf("Expected 42, got %d", result)
	}

	// Test with fallback
	result = getEnvAsInt("NON_EXISTENT", 10)
	if result != 10 {
		t.Errorf("Expected fallback value 10, got %d", result)
	}
}

func TestGetEnvAsBool(t *testing.T) {
	// Test with valid boolean
	os.Setenv("TEST_BOOL", "true")
	defer os.Unsetenv("TEST_BOOL")

	result := getEnvAsBool("TEST_BOOL", false)
	if result != true {
		t.Errorf("Expected true, got %v", result)
	}

	// Test with fallback
	result = getEnvAsBool("NON_EXISTENT", false)
	if result != false {
		t.Errorf("Expected fallback value false, got %v", result)
	}
}
