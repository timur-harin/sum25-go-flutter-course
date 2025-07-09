package main

import (
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/repository"
	"lab04-backend/models"

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
			log.Println("Failed to close database:", err)
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
	// --- DEMO: Create a user ---
	newUser := &models.CreateUserRequest{
		Name:  "Alice Johnson",
		Email: "alice@example.com",
	}

	if err := newUser.Validate(); err != nil {
		log.Fatal("Validation failed:", err)
	}

	createdUser, err := userRepo.Create(newUser)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}

	fmt.Printf("👤 Created user: %+v\n", createdUser)

	// --- DEMO: Create a post for that user ---
	newPost := &models.CreatePostRequest{
		UserID:    createdUser.ID,
		Title:     "Hello World",
		Content:   "This is my first blog post!",
		Published: true,
	}

	if err := newPost.Validate(); err != nil {
		log.Fatal("Validation failed:", err)
	}

	createdPost, err := postRepo.Create(newPost)
	if err != nil {
		log.Fatal("Failed to create post:", err)
	}

	fmt.Printf("📝 Created post: %+v\n", createdPost)

	// --- DEMO: Count users ---
	count, err := userRepo.Count()
	if err != nil {
		log.Fatal("Failed to count users:", err)
	}
	fmt.Printf("📊 Total users: %d\n", count)

	// --- DEMO: Get all users ---
	users, err := userRepo.GetAll()
	if err != nil {
		log.Fatal("Failed to get all users:", err)
	}
	fmt.Println("📋 All users:")
	for _, u := range users {
		fmt.Printf("- %+v\n", u)
	}
}

