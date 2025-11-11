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
	postRepo := repository.NewPostRepository(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	userRepo.Create(&models.CreateUserRequest{
		Name: "alex",
		Email: "test@example.com",
	})
	user, err := userRepo.GetByID(1)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%+v", user)
	userRepo.Create(&models.CreateUserRequest{
		Name: "bob",
		Email: "test2@example.com",
	})
	users, err := userRepo.GetAll()
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%+v", users)
}
