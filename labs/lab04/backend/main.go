package main

import (
	"fmt"
	"log"

	"lab04-backend/database"

	"lab04-backend/models"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
	"golang.org/x/crypto/bcrypt"
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

	// Hash password
	rawPassword := "securepassword"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(rawPassword), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal("Failed to hash password:", err)
	}

	// Create sample user
	userReq := &models.CreateUserRequest{
		Name:         "Alice",
		Email:        "alice@example.com",
		PasswordHash: string(hashedPassword),
	}
	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Println("User created:", user)

	// Create sample post
	postReq := &models.CreatePostRequest{
		UserID:    user.ID,
		Title:     "My First Post",
		Content:   "Hello, this is my first post!",
		Published: true,
	}
	post, err := postRepo.Create(postReq)
	if err != nil {
		log.Fatal("Failed to create post:", err)
	}
	fmt.Println("Post created:", post)

	// Fetch and display all posts
	posts, err := postRepo.GetAll()
	if err != nil {
		log.Fatal("Failed to fetch posts:", err)
	}
	fmt.Println("All Posts:")
	for _, p := range posts {
		fmt.Printf(" - %s by user %d\n", p.Title, p.UserID)
	}

	// Count total users
	userCount, err := userRepo.Count()
	if err != nil {
		log.Fatal("Failed to count users:", err)
	}
	fmt.Printf("Total users in system: %d\n", userCount)
}
