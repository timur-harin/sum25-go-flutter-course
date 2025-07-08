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
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close()

	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	userRepo := repository.NewUserRepository(db)

	req := &models.CreateUserRequest{
		Name:  "Alice Test",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(req)
	if err != nil {
		log.Fatalf("Create user failed: %v", err)
	}
	fmt.Printf("Created user: %+v\n", user)

	got, err := userRepo.GetByID(user.ID)
	if err != nil {
		log.Fatalf("GetByID failed: %v", err)
	}
	fmt.Printf("Fetched user by ID: %+v\n", got)

	count, err := userRepo.Count()
	if err != nil {
		log.Fatalf("Count failed: %v", err)
	}
	fmt.Printf("Total users: %d\n", count)
}
