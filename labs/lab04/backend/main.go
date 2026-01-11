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

	// Run migrations (using goose-based approach)
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("✅ Database initialized successfully!")
	fmt.Printf("🧑‍💼 User repository: %T\n", userRepo)
	fmt.Printf("📝 Post repository: %T\n", postRepo)

	// Add demo user
	userReq := &models.CreateUserRequest{
		Name:  "Alice",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("👤 Created user: %+v\n", user)

	// Add demo post
	postReq := &models.CreatePostRequest{
		UserID:    user.ID,
		Title:     "My First Post",
		Content:   "This is a demo post.",
		Published: true,
	}
	post, err := postRepo.Create(postReq)
	if err != nil {
		log.Fatal("Failed to create post:", err)
	}
	fmt.Printf("📝 Created post: %+v\n", post)
}
