package main

import (
	"context"
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

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// Create new user
	userReq := &models.CreateUserRequest{
		Name:  "Alice Johnson",
		Email: "alice228@example.com",
	}
	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Fatalf("Error creating user: %v", err)
	}
	fmt.Printf("Created user: %+v\n", user)

	// Create post for user
	postReq := &models.CreatePostRequest{
		UserID:    user.ID,
		Title:     "First Post",
		Content:   "This is the content of the first post.",
		Published: true,
	}
	postRepoSQL := repository.NewPostRepository(db)
	post, err := postRepoSQL.Create(postReq)
	if err != nil {
		log.Fatalf("Error creating post: %v", err)
	}
	fmt.Printf("Created post: %+v\n", post)

	// Search published posts using search service
	searchService := repository.NewSearchService(db)
	posts, err := searchService.SearchPosts(context.Background(), repository.SearchFilters{
		Published: ptrBool(true),
		Limit:     10,
		OrderBy:   "created_at",
		OrderDir:  "DESC",
	})
	if err != nil {
		log.Fatalf("Error searching posts: %v", err)
	}
	fmt.Printf("Found %d published posts:\n", len(posts))
	for _, p := range posts {
		fmt.Printf("- %s by user #%d\n", p.Title, p.UserID)
	}
}

func ptrBool(b bool) *bool {
	return &b
}
