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
	log.Println("Starting application...")

	// Initialize database connection
	db, err := database.InitDB()
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB(db) // Use the helper function for closing

	log.Println("Database connection successful.")

	// Run migrations (using goose-based approach)
	if err := database.RunMigrations(db); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	log.Println("Database migrations applied successfully.")

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("----------------------------------------")
	fmt.Println("Repositories initialized successfully!")
	fmt.Printf("User repository type: %T\n", userRepo)
	fmt.Printf("Post repository type: %T\n", postRepo)
	fmt.Println("----------------------------------------")

	// Demo data operations
	runDemo(userRepo, postRepo)
}

// runDemo demonstrates some basic CRUD operations using the repositories.
func runDemo(userRepo *repository.UserRepository, postRepo *repository.PostRepository) {
	fmt.Println("\n🚀 Running demo operations...")

	// 1. Create a new user
	fmt.Println("\n[1] Creating a new user...")
	userReq := &models.CreateUserRequest{
		Name:  "Alice Demo",
		Email: "alice.demo@example.com",
	}
	alice, err := userRepo.Create(userReq)
	if err != nil {
		log.Printf("Error creating user: %v", err)
		return
	}
	fmt.Printf("✅ User created: ID=%d, Name=%s, Email=%s\n", alice.ID, alice.Name, alice.Email)

	// 2. Create another user
	bob, err := userRepo.Create(&models.CreateUserRequest{Name: "Bob Demo", Email: "bob.demo@example.com"})
	if err != nil {
		log.Printf("Error creating user: %v", err)
		return
	}
	fmt.Printf("✅ User created: ID=%d, Name=%s, Email=%s\n", bob.ID, bob.Name, bob.Email)

	// 3. Get all users
	fmt.Println("\n[2] Getting all users...")
	users, err := userRepo.GetAll()
	if err != nil {
		log.Printf("Error getting all users: %v", err)
	} else {
		fmt.Printf("✅ Found %d users:\n", len(users))
		for _, u := range users {
			fmt.Printf("  - User ID: %d, Name: %s\n", u.ID, u.Name)
		}
	}

	// 4. Create a post for Alice
	fmt.Println("\n[3] Creating a post for Alice...")
	postReq := &models.CreatePostRequest{
		UserID:    alice.ID,
		Title:     "My First Post",
		Content:   "This is a demo post created from the main application.",
		Published: true,
	}
	post, err := postRepo.Create(postReq)
	if err != nil {
		log.Printf("Error creating post: %v", err)
	} else {
		fmt.Printf("✅ Post created: ID=%d, Title='%s'\n", post.ID, post.Title)
	}

	// 5. Get posts by Alice's user ID
	fmt.Println("\n[4] Getting all posts by Alice...")
	alicePosts, err := postRepo.GetByUserID(alice.ID)
	if err != nil {
		log.Printf("Error getting Alice's posts: %v", err)
	} else {
		fmt.Printf("✅ Found %d posts for Alice:\n", len(alicePosts))
		for _, p := range alicePosts {
			fmt.Printf("  - Post ID: %d, Title: %s\n", p.ID, p.Title)
		}
	}

	// 6. Update Bob's name
	fmt.Println("\n[5] Updating Bob's name...")
	updatedName := "Robert Demo"
	updatedBob, err := userRepo.Update(bob.ID, &models.UpdateUserRequest{Name: &updatedName})
	if err != nil {
		log.Printf("Error updating Bob: %v", err)
	} else {
		fmt.Printf("✅ User updated: ID=%d, New Name=%s\n", updatedBob.ID, updatedBob.Name)
	}

	// 7. Delete Alice
	fmt.Println("\n[6] Deleting Alice...")
	err = userRepo.Delete(alice.ID)
	if err != nil {
		log.Printf("Error deleting Alice: %v", err)
	} else {
		fmt.Printf("✅ User with ID %d deleted.\n", alice.ID)
	}

	// 8. Count remaining users
	fmt.Println("\n[7] Counting remaining users...")
	count, err := userRepo.Count()
	if err != nil {
		log.Printf("Error counting users: %v", err)
	} else {
		fmt.Printf("✅ Total users remaining: %d\n", count)
	}

	fmt.Println("\n🎉 Demo finished.")
}
