package main

import (
	"fmt"
	"log"
	"lab04-backend/models"
	"lab04-backend/database"
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

	// Add some demo data operations here
	
	// Create a new user
	userReq := &models.CreateUserRequest{
		Name:  "Yan",
		Email: "Toples@UmnyChelovekVOchkahSkachatOboi.com",
	}

	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Fatal("failed to create:", err)
	}
	fmt.Printf("created user: %+v\n", user)


	// Update user
	name := "SmartMan"
	updateReq := &models.UpdateUserRequest{
		Name:  &name,
		Email: nil,
	}
	updatedUser, err := userRepo.Update(user.ID, updateReq)
	if err != nil {
		log.Fatal("failed to update user:", err)
	}
	fmt.Printf("updated user: %+v\n", updatedUser)

	// Delete user
	if err := userRepo.Delete(user.ID); err != nil {
		log.Fatal("failed to delete user:", err)
	}
	fmt.Println("user deleted!")
}
