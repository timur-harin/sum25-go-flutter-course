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
	defer func() {
		if err := database.CloseDB(db); err != nil {
			log.Printf("failed to close database: %v", err)
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
		Name:  "John Ultrakill",
		Email: "gabrielsux@hell.com",
	}

	if err := newUser.Validate(); err != nil {
		log.Fatalf("validation failed: %v", err)
	}

	createdUser, err := userRepo.Create(newUser)
	if err != nil {
		log.Fatalf("failed to create user: %v", err)
	}

	fmt.Printf("Creates user: %+v", createdUser)

	newPost := &models.CreatePostRequest{
		UserID:    createdUser.ID,
		Title:     "IM GOING TO ULTRAKILL YOU",
		Content:   "MAY YOUR L's BE MANY, AND YOUR [redacted] FEW",
		Published: true,
	}

	if err := newPost.Validate(); err != nil {
		log.Fatalf("validation failed: %v", err)
	}

	createdPost, err := postRepo.Create(newPost)
	if err != nil {
		log.Fatalf("failed to create post: %v", err)
	}

	fmt.Printf("Created post %+v", createdPost)

	count, err := userRepo.Count()
	if err != nil {
		log.Fatalf("failed to count users: %v", err)
	}
	fmt.Printf("Total users: %d", count)

	users, err := userRepo.GetAll()
	if err != nil {
		log.Fatalf("failed to get all users: %v", err)
	}
	fmt.Println("All users:")
	for _, u := range users {
		fmt.Printf("- %+v\n", u)
	}
}
