package main

import (
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer database.CloseDB(db)

	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// Demo: print user count and post count
	userCount, err := userRepo.Count()
	if err != nil {
		log.Println("Error getting user count:", err)
	} else {
		fmt.Printf("User count: %d\n", userCount)
	}
	postCount, err := postRepo.Count()
	if err != nil {
		log.Println("Error getting post count:", err)
	} else {
		fmt.Printf("Post count: %d\n", postCount)
	}
}
