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
	// TODO: Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close()

	// TODO: Run migrations (using goose-based approach)
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// TODO: Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	// Demo operations
	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// Demo: create a new user
	newUser, err := userRepo.Create(&models.CreateUserRequest{
		Name:  "Alice",
		Email: "alice@example.com",
	})
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("Created user: %+v\n", newUser)

	// Demo: fetch user by ID
	fetchedUser, err := userRepo.GetByID(newUser.ID)
	if err != nil {
		log.Fatal("Failed to fetch user:", err)
	}
	fmt.Printf("Fetched user: %+v\n", fetchedUser)

	// Demo: update user
	updatedName := "Alice Cooper"
	updateReq := &models.UpdateUserRequest{Name: &updatedName}
	updatedUser, err := userRepo.Update(newUser.ID, updateReq)
	if err != nil {
		log.Fatal("Failed to update user:", err)
	}
	fmt.Printf("Updated user: %+v\n", updatedUser)

	// Demo: delete user
	if err := userRepo.Delete(newUser.ID); err != nil {
		log.Fatal("Failed to delete user:", err)
	}
	fmt.Println("User deleted successfully")
}
