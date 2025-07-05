package storage

import (
	"testing"
)

func TestNewMemoryStorage(t *testing.T) {
	storage := NewMemoryStorage()

	if storage == nil {
		t.Fatal("NewMemoryStorage returned nil")
	}

	count := storage.Count()
	if count != 0 {
		t.Errorf("Expected empty storage, got %d messages", count)
	}
}

func TestMemoryStorageCRUD(t *testing.T) {
	storage := NewMemoryStorage()

	// Test Create
	message, err := storage.Create("testuser", "test content")
	if err != nil {
		t.Fatalf("Create failed: %v", err)
	}

	if message == nil {
		t.Fatal("Create returned nil message")
	}

	// Test GetByID
	retrieved, err := storage.GetByID(1)
	if err != nil {
		t.Fatalf("GetByID failed: %v", err)
	}

	if retrieved == nil {
		t.Fatal("GetByID returned nil message")
	}

	// Test GetAll
	messages := storage.GetAll()
	if len(messages) != 1 {
		t.Errorf("Expected 1 message, got %d", len(messages))
	}

	// Test Update
	updated, err := storage.Update(1, "updated content")
	if err != nil {
		t.Fatalf("Update failed: %v", err)
	}

	if updated == nil {
		t.Fatal("Update returned nil message")
	}

	// Test Delete
	err = storage.Delete(1)
	if err != nil {
		t.Fatalf("Delete failed: %v", err)
	}

	// Verify deletion
	count := storage.Count()
	if count != 0 {
		t.Errorf("Expected empty storage after delete, got %d messages", count)
	}
}

func TestMemoryStorageErrors(t *testing.T) {
	storage := NewMemoryStorage()

	// Test GetByID with non-existent ID
	_, err := storage.GetByID(999)
	if err == nil {
		t.Error("Expected error for non-existent ID")
	}

	// Test Update with non-existent ID
	_, err = storage.Update(999, "content")
	if err == nil {
		t.Error("Expected error for updating non-existent message")
	}

	// Test Delete with non-existent ID
	err = storage.Delete(999)
	if err == nil {
		t.Error("Expected error for deleting non-existent message")
	}
}

func TestMemoryStorageConcurrency(t *testing.T) {
	storage := NewMemoryStorage()

	// Test concurrent writes
	done := make(chan bool, 10)
	for i := 0; i < 10; i++ {
		go func(id int) {
			_, err := storage.Create("user", "content")
			if err != nil {
				t.Errorf("Concurrent create failed: %v", err)
			}
			done <- true
		}(i)
	}

	// Wait for all goroutines
	for i := 0; i < 10; i++ {
		<-done
	}

	count := storage.Count()
	if count != 10 {
		t.Errorf("Expected 10 messages after concurrent writes, got %d", count)
	}
}
