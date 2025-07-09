package main

import (
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	// TODO: Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer func() {
		if err := database.CloseDB(db); err != nil {
			log.Println("Warning: failed to close DB:", err)
		}
	}()

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

	// TODO: Add some demo data operations here
	// You can test your CRUD operations
	newUser := &models.CreateUserRequest{
		Name:  "name",
		Email: "test@test.com",
	}
	user, err := userRepo.Create(newUser)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("Created User: %+v\n", user)
}
