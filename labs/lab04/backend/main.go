package main

import (
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/models"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	// Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close() // Always close the database connection when main() exits

	// Run migrations (using goose-based approach)
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// Add some demo data operations here

	// Create a new user
	createUserReq := &models.CreateUserRequest{
		Name:  "Alice",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(createUserReq)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("Created user: %+v\n", user)

	// Get user by ID
	gotUser, err := userRepo.GetByID(user.ID)
	if err != nil {
		log.Fatal("Failed to get user by ID:", err)
	}
	fmt.Printf("Fetched user by ID: %+v\n", gotUser)

	// Update user
	updateReq := &models.UpdateUserRequest{
		Name:  strPtr("Alice Updated"),
		Email: nil, // Email will not be updated
	}
	updatedUser, err := userRepo.Update(user.ID, updateReq)
	if err != nil {
		log.Fatal("Failed to update user:", err)
	}
	fmt.Printf("Updated user: %+v\n", updatedUser)

	// Count users
	count, err := userRepo.Count()
	if err != nil {
		log.Fatal("Failed to count users:", err)
	}
	fmt.Printf("Total users: %d\n", count)

	// Delete user
	if err := userRepo.Delete(user.ID); err != nil {
		log.Fatal("Failed to delete user:", err)
	}
	fmt.Println("User deleted successfully!")

	// You can add similar demo operations for postRepo (create, get, update, delete posts)
}

// strPtr returns a pointer to the given string value
func strPtr(s string) *string {
	return &s
}
