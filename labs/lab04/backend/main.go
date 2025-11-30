package main

import (
	"context"
	"fmt"
	"log"
	"time"
	

	"lab04-backend/database"
	"lab04-backend/models"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	// Initialize database with default configuration
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer func() {
		if err := database.CloseDB(db); err != nil {
			log.Println("Error closing database:", err)
		}
	}()

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Initialize GORM for CategoryRepository
	gormDB, err := gorm.Open(sqlite.Open(database.DefaultConfig().DatabasePath), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to initialize GORM:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)
	categoryRepo := repository.NewCategoryRepository(gormDB)
	searchService := repository.NewSearchService(db)

	// Demo operations
	fmt.Println("Database initialized successfully!")
	fmt.Println("Running demo operations...")

	// User CRUD demo
	fmt.Println("\n=== User CRUD Demo ===")
	userReq := &models.CreateUserRequest{
		Name:  "John Doe",
		Email: "john@example.com",
	}
	createdUser, err := userRepo.Create(userReq)
	if err != nil {
		log.Println("Error creating user:", err)
	} else {
		fmt.Printf("Created user: %+v\n", createdUser)
	}

	// Post CRUD demo
	fmt.Println("\n=== Post CRUD Demo ===")
	postReq := &models.CreatePostRequest{
		UserID:    createdUser.ID,
		Title:     "First Post",
		Content:   "This is my first post content",
		Published: true,
	}
	createdPost, err := postRepo.Create(postReq)
	if err != nil {
		log.Println("Error creating post:", err)
	} else {
		fmt.Printf("Created post: %+v\n", createdPost)
	}

	// Category CRUD demo (using GORM)
	fmt.Println("\n=== Category CRUD Demo ===")
	category := &models.Category{
		Name:        "Technology",
		Description: "Posts about technology",
		Color:       "#3498db",
	}
	if err := categoryRepo.Create(category); err != nil {
		log.Println("Error creating category:", err)
	} else {
		fmt.Printf("Created category: %+v\n", category)
	}

	// Search demo
	fmt.Println("\n=== Search Demo ===")
	posts, err := searchService.SearchPosts(context.Background(), repository.SearchFilters{
		Query:    "first",
		Limit:    10,
		OrderBy:  "created_at",
		OrderDir: "DESC",
	})
	if err != nil {
		log.Println("Error searching posts:", err)
	} else {
		fmt.Println("Found posts:")
		for _, p := range posts {
			fmt.Printf("- %s (ID: %d)\n", p.Title, p.ID)
		}
	}

	// Statistics demo
	fmt.Println("\n=== Statistics Demo ===")
	stats, err := searchService.GetPostStats(context.Background())
	if err != nil {
		log.Println("Error getting stats:", err)
	} else {
		fmt.Printf("Post statistics:\nTotal posts: %d\nPublished posts: %d\nActive users: %d\nAvg content length: %.2f\n",
			stats.TotalPosts, stats.PublishedPosts, stats.ActiveUsers, stats.AvgContentLength)
	}

	// Migration status check
	fmt.Println("\n=== Migration Status ===")
	if err := database.GetMigrationStatus(db); err != nil {
		log.Println("Error getting migration status:", err)
	}

	// Wait a bit to see the output
	time.Sleep(1 * time.Second)
	fmt.Println("\nDemo completed successfully!")
}