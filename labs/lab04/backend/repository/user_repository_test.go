package repository

import (
	"os"
	"testing"

	"lab04-backend/database"
	"lab04-backend/models"
)

func setupTestDB(t *testing.T) (*UserRepository, func()) {
	// Create test database
	testDB := "./test_user_repo.db"
	config := &database.Config{
		DatabasePath:    testDB,
		MaxOpenConns:    5,
		MaxIdleConns:    1,
		ConnMaxLifetime: 0,
		ConnMaxIdleTime: 0,
	}

	db, err := database.InitDBWithConfig(config)
	if err != nil {
		t.Fatalf("Failed to initialize test database: %v", err)
	}

	err = database.RunMigrations(db)
	if err != nil {
		t.Fatalf("Failed to migrate test database: %v", err)
	}

	repo := NewUserRepository(db)

	// Return cleanup function
	cleanup := func() {
		database.CloseDB(db)
		os.Remove(testDB)
	}

	return repo, cleanup
}

func TestUserRepository_Create(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	req := &models.CreateUserRequest{
		Name:  "John Doe",
		Email: "john@example.com",
	}

	user, err := repo.Create(req)
	if err != nil {
		t.Fatalf("Create() failed: %v", err)
	}

	if user == nil {
		t.Fatal("Create() returned nil user")
	}

	if user.ID == 0 {
		t.Error("Create() should set user ID")
	}

	if user.Name != req.Name {
		t.Errorf("Create() name = %v, want %v", user.Name, req.Name)
	}

	if user.Email != req.Email {
		t.Errorf("Create() email = %v, want %v", user.Email, req.Email)
	}

	if user.CreatedAt.IsZero() {
		t.Error("Create() should set CreatedAt")
	}

	if user.UpdatedAt.IsZero() {
		t.Error("Create() should set UpdatedAt")
	}
}

func TestUserRepository_GetByID(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Create a user first
	req := &models.CreateUserRequest{
		Name:  "Jane Doe",
		Email: "jane@example.com",
	}

	createdUser, err := repo.Create(req)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	// Test GetByID
	foundUser, err := repo.GetByID(createdUser.ID)
	if err != nil {
		t.Fatalf("GetByID() failed: %v", err)
	}

	if foundUser == nil {
		t.Fatal("GetByID() returned nil user")
	}

	if foundUser.ID != createdUser.ID {
		t.Errorf("GetByID() ID = %v, want %v", foundUser.ID, createdUser.ID)
	}

	if foundUser.Name != createdUser.Name {
		t.Errorf("GetByID() name = %v, want %v", foundUser.Name, createdUser.Name)
	}

	if foundUser.Email != createdUser.Email {
		t.Errorf("GetByID() email = %v, want %v", foundUser.Email, createdUser.Email)
	}

	// Test GetByID with non-existent ID
	_, err = repo.GetByID(99999)
	if err == nil {
		t.Error("GetByID() should return error for non-existent user")
	}
}

func TestUserRepository_GetByEmail(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Create a user first
	req := &models.CreateUserRequest{
		Name:  "Bob Smith",
		Email: "bob@example.com",
	}

	createdUser, err := repo.Create(req)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	// Test GetByEmail
	foundUser, err := repo.GetByEmail(createdUser.Email)
	if err != nil {
		t.Fatalf("GetByEmail() failed: %v", err)
	}

	if foundUser == nil {
		t.Fatal("GetByEmail() returned nil user")
	}

	if foundUser.Email != createdUser.Email {
		t.Errorf("GetByEmail() email = %v, want %v", foundUser.Email, createdUser.Email)
	}

	// Test GetByEmail with non-existent email
	_, err = repo.GetByEmail("nonexistent@example.com")
	if err == nil {
		t.Error("GetByEmail() should return error for non-existent email")
	}
}

func TestUserRepository_GetAll(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Test empty database
	users, err := repo.GetAll()
	if err != nil {
		t.Fatalf("GetAll() failed: %v", err)
	}

	if len(users) != 0 {
		t.Errorf("GetAll() should return empty slice for empty database, got %d users", len(users))
	}

	// Create multiple users
	userRequests := []*models.CreateUserRequest{
		{Name: "User One", Email: "user1@example.com"},
		{Name: "User Two", Email: "user2@example.com"},
		{Name: "User Three", Email: "user3@example.com"},
	}

	for _, req := range userRequests {
		_, err := repo.Create(req)
		if err != nil {
			t.Fatalf("Failed to create user: %v", err)
		}
	}

	// Test GetAll with users
	users, err = repo.GetAll()
	if err != nil {
		t.Fatalf("GetAll() failed: %v", err)
	}

	if len(users) != len(userRequests) {
		t.Errorf("GetAll() returned %d users, want %d", len(users), len(userRequests))
	}
}

func TestUserRepository_Update(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Create a user first
	req := &models.CreateUserRequest{
		Name:  "Original Name",
		Email: "original@example.com",
	}

	createdUser, err := repo.Create(req)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	// Test update
	newName := "Updated Name"
	newEmail := "updated@example.com"
	updateReq := &models.UpdateUserRequest{
		Name:  &newName,
		Email: &newEmail,
	}

	updatedUser, err := repo.Update(createdUser.ID, updateReq)
	if err != nil {
		t.Fatalf("Update() failed: %v", err)
	}

	if updatedUser == nil {
		t.Fatal("Update() returned nil user")
	}

	if updatedUser.Name != newName {
		t.Errorf("Update() name = %v, want %v", updatedUser.Name, newName)
	}

	if updatedUser.Email != newEmail {
		t.Errorf("Update() email = %v, want %v", updatedUser.Email, newEmail)
	}

	if !updatedUser.UpdatedAt.After(createdUser.UpdatedAt) {
		t.Error("Update() should update UpdatedAt timestamp")
	}

	// Test update with non-existent ID
	_, err = repo.Update(99999, updateReq)
	if err == nil {
		t.Error("Update() should return error for non-existent user")
	}
}

func TestUserRepository_Delete(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Create a user first
	req := &models.CreateUserRequest{
		Name:  "To Be Deleted",
		Email: "delete@example.com",
	}

	createdUser, err := repo.Create(req)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	// Test delete
	err = repo.Delete(createdUser.ID)
	if err != nil {
		t.Fatalf("Delete() failed: %v", err)
	}

	// Verify user is deleted
	_, err = repo.GetByID(createdUser.ID)
	if err == nil {
		t.Error("User should be deleted and GetByID should return error")
	}

	// Test delete with non-existent ID
	err = repo.Delete(99999)
	if err == nil {
		t.Error("Delete() should return error for non-existent user")
	}
}

func TestUserRepository_Count(t *testing.T) {
	repo, cleanup := setupTestDB(t)
	defer cleanup()

	// Test count with empty database
	count, err := repo.Count()
	if err != nil {
		t.Fatalf("Count() failed: %v", err)
	}

	if count != 0 {
		t.Errorf("Count() should return 0 for empty database, got %d", count)
	}

	// Create users
	userRequests := []*models.CreateUserRequest{
		{Name: "Count User 1", Email: "count1@example.com"},
		{Name: "Count User 2", Email: "count2@example.com"},
	}

	for _, req := range userRequests {
		_, err := repo.Create(req)
		if err != nil {
			t.Fatalf("Failed to create user: %v", err)
		}
	}

	// Test count with users
	count, err = repo.Count()
	if err != nil {
		t.Fatalf("Count() failed: %v", err)
	}

	if count != len(userRequests) {
		t.Errorf("Count() returned %d, want %d", count, len(userRequests))
	}
}
