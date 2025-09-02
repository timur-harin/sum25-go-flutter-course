package main

import (
	"fmt"
	"lab04-backend/models"
	"log"

	"lab04-backend/database"
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

	// Demo operations
	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	newUser := &models.CreateUserRequest{
		Name:  "Alice Example",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(newUser)
	if err != nil {
		log.Fatal("Create user failed:", err)
	}
	fmt.Println("Created user:", user)

	gotUser, err := userRepo.GetByID(user.ID)
	if err != nil {
		log.Fatal("GetByID failed:", err)
	}
	fmt.Println("Fetched user by ID:", gotUser)

	updatedName := "Alice Updated"
	updateReq := &models.UpdateUserRequest{
		Name: &updatedName,
	}
	updatedUser, err := userRepo.Update(user.ID, updateReq)
	if err != nil {
		log.Fatal("Update failed:", err)
	}
	fmt.Println("Updated user:", updatedUser)

	err = userRepo.Delete(user.ID)
	if err != nil {
		log.Fatal("Delete failed:", err)
	}
	fmt.Println("Deleted user successfully")

}
