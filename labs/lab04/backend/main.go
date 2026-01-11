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
	defer db.Close()

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// === Demo: Create a new user ===
	userReq := &models.CreateUserRequest{
		Name:  "Alice Example",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Println("Created user:", user)

	// === Demo: Get user by ID ===
	fetchedUser, err := userRepo.GetByID(user.ID)
	if err != nil {
		log.Fatal("Failed to get user by ID:", err)
	}
	fmt.Println("Fetched user by ID:", fetchedUser)

	// === Demo: Update user ===
	newName := "Alice Updated"
	newEmail := "alice.updated@example.com"
	updateReq := &models.UpdateUserRequest{
		Name:  &newName,
		Email: &newEmail,
	}
	updatedUser, err := userRepo.Update(user.ID, updateReq)
	if err != nil {
		log.Fatal("Failed to update user:", err)
	}
	fmt.Println("Updated user:", updatedUser)

	// === Demo: Count users ===
	count, err := userRepo.Count()
	if err != nil {
		log.Fatal("Failed to count users:", err)
	}
	fmt.Println("Total users in DB:", count)

	// === Demo: Delete user ===
	if err := userRepo.Delete(user.ID); err != nil {
		log.Fatal("Failed to delete user:", err)
	}
	fmt.Println("User deleted successfully.")

}
