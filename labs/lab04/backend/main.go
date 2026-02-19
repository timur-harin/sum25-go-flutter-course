package main

import (
	"fmt"
	"log"
	"time"

	"lab04-backend/database"
	"lab04-backend/repository"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	// Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer func() {
		if err := database.CloseDB(db); err != nil {
			log.Printf("Error closing database: %v", err)
		}
	}()

	// Initialize GORM for CategoryRepository
	gormDB, err := gorm.Open(sqlite.Open("./lab04.db"), &gorm.Config{})
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
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)
	fmt.Printf("Category repository: %T\n", categoryRepo)
	fmt.Printf("Search service: %T\n", searchService)

	// Wait a bit to see the output
	time.Sleep(1 * time.Second)
}
