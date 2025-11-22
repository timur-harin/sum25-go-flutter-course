package main

import (
	"database/sql"
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/models"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	// TODO: Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close()

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
	createReq := &models.CreateUserRequest{
		Name:  "Alice",
		Email: "alice@example.com",
	}
	createdUser, err := userRepo.Create(createReq)
	if err != nil {
		log.Fatal("Error creating user:", err)
	}
	fmt.Println("✅ Created user:", createdUser)

	// 2️⃣ Get user by ID
	fetchedUser, err := userRepo.GetByID(createdUser.ID)
	if err != nil {
		log.Fatal("Error fetching user by ID:", err)
	}
	fmt.Println("✅ Fetched user by ID:", fetchedUser)

	// 3️⃣ Update user
	newName := "Alice Updated"
	updateReq := &models.UpdateUserRequest{
		Name: &newName,
	}
	updatedUser, err := userRepo.Update(createdUser.ID, updateReq)
	if err != nil {
		log.Fatal("Error updating user:", err)
	}
	fmt.Println("✅ Updated user:", updatedUser)

	// 4️⃣ Get all users
	users, err := userRepo.GetAll()
	if err != nil {
		log.Fatal("Error getting all users:", err)
	}
	fmt.Println("✅ All users:")
	for _, u := range users {
		fmt.Printf("- %+v\n", u)
	}

	// 5️⃣ Count users
	count, err := userRepo.Count()
	if err != nil {
		log.Fatal("Error counting users:", err)
	}
	fmt.Println("✅ Total active users:", count)

	// 6️⃣ Soft delete user
	if err := userRepo.Delete(createdUser.ID); err != nil {
		log.Fatal("Error deleting user:", err)
	}
	fmt.Println("✅ User soft-deleted")

	// 7️⃣ Try to fetch deleted user
	deletedUser, err := userRepo.GetByID(createdUser.ID)
	if err != nil {
		if err == sql.ErrNoRows {
			fmt.Println("✅ Deleted user not found (as expected)")
		} else {
			log.Fatal("Error fetching deleted user:", err)
		}
	} else {
		log.Fatal("Unexpectedly fetched deleted user:", deletedUser)
	}
}
