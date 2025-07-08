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
	// Initialize DB
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer func() {
		if err := database.CloseDB(db); err != nil {
			log.Println("Warning: failed to close DB:", err)
		}
	}()

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repositories
	userRepo := repository.NewUserRepository(db)
	fmt.Println("Database initialized and migrations applied!")

	// DEMO: Create a new user
	newUserReq := &models.CreateUserRequest{
		Name:  "Alice Example",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(newUserReq)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("Created User: %+v\n", user)

	// DEMO: Fetch user by ID
	fetched, err := userRepo.GetByID(user.ID)
	if err != nil {
		log.Fatal("Failed to fetch user by ID:", err)
	}
	fmt.Printf(" User by ID: %+v\n", fetched)

	// DEMO: List all users
	users, err := userRepo.GetAll()
	if err != nil {
		log.Fatal("Failed to get all users:", err)
	}
	fmt.Println("All Users:")
	for _, u := range users {
		fmt.Printf("- %+v\n", u)
	}

	fmt.Println("Demo completed successfully!")
}
