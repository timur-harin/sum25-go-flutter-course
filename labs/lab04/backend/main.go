package main

import (
	"fmt"
	"log"
	"context"

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

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)
	searchService := repository.NewSearchService(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)
	fmt.Printf("Search service: %T\n", searchService)

	// Demo operations
	fmt.Println("\n===== USER OPERATIONS =====")
	// Create a user
	newUser := &models.CreateUserRequest{
		Name:  "John Doe",
		Email: "john.doe@example.com",
	}
	createdUser, err := userRepo.Create(newUser)
	if err != nil {
		log.Fatal("Failed to create user:", err)
	}
	fmt.Printf("Created user: ID=%d, Name=%s, Email=%s\n",
		createdUser.ID, createdUser.Name, createdUser.Email)

	// Get user by ID
	fetchedUser, err := userRepo.GetByID(createdUser.ID)
	if err != nil {
		log.Fatal("Failed to get user:", err)
	}
	fmt.Printf("Fetched user: ID=%d, Name=%s\n", fetchedUser.ID, fetchedUser.Name)

	// Update user
	updateReq := models.UpdateUserRequest{
		Name:  ptrString("Johnathan Doe"),
		Email: ptrString("johnathan.doe@example.com"),
	}
	updatedUser, err := userRepo.Update(fetchedUser.ID, &updateReq)
	if err != nil {
		log.Fatal("Failed to update user:", err)
	}
	fmt.Printf("Updated user: ID=%d, Name=%s, Email=%s\n",
		updatedUser.ID, updatedUser.Name, updatedUser.Email)

	fmt.Println("\n===== POST OPERATIONS =====")
	// Create a post
	newPost := &models.CreatePostRequest{
		UserID:    createdUser.ID,
		Title:     "My First Post",
		Content:   "This is the content of my first post",
		Published: true,
	}
	createdPost, err := postRepo.Create(newPost)
	if err != nil {
		log.Fatal("Failed to create post:", err)
	}
	fmt.Printf("Created post: ID=%d, Title=%s\n", createdPost.ID, createdPost.Title)

	// Get post by ID
	fetchedPost, err := postRepo.GetByID(createdPost.ID)
	if err != nil {
		log.Fatal("Failed to get post:", err)
	}
	fmt.Printf("Fetched post: ID=%d, Title=%s, Content=%s\n",
		fetchedPost.ID, fetchedPost.Title, fetchedPost.Content)

	// Update post
	postUpdateReq := models.UpdatePostRequest{
		Title:     ptrString("My Updated Post"),
		Content:   ptrString("Updated content with more details"),
		Published: ptrBool(false),
	}
	updatedPost, err := postRepo.Update(fetchedPost.ID, &postUpdateReq)
	if err != nil {
		log.Fatal("Failed to update post:", err)
	}
	fmt.Printf("Updated post: ID=%d, Title=%s, Published=%v\n",
		updatedPost.ID, updatedPost.Title, updatedPost.Published)

	// Create another post for search testing
	anotherPost := &models.CreatePostRequest{
		UserID:    createdUser.ID,
		Title:     "Go Programming",
		Content:   "Learning Go is fun and efficient",
		Published: true,
	}
	_, err = postRepo.Create(anotherPost)
	if err != nil {
		log.Fatal("Failed to create second post:", err)
	}

	fmt.Println("\n===== SEARCH OPERATIONS =====")
	// Search posts
	posts, err := searchService.SearchPosts(context.Background(), repository.SearchFilters{
		Query:     "programming",
		Published: ptrBool(true),
		Limit:     10,
	})
	if err != nil {
		log.Fatal("Failed to search posts:", err)
	}
	fmt.Printf("Found %d posts matching 'programming':\n", len(posts))
	for i, post := range posts {
		fmt.Printf("%d. ID=%d, Title=%s\n", i+1, post.ID, post.Title)
	}

	// Get post statistics
	stats, err := searchService.GetPostStats(context.Background())
	if err != nil {
		log.Fatal("Failed to get post stats:", err)
	}
	fmt.Printf("\nPost statistics:\n")
	fmt.Printf("- Total posts: %d\n", stats.TotalPosts)
	fmt.Printf("- Published posts: %d\n", stats.PublishedPosts)
	fmt.Printf("- Active users: %d\n", stats.ActiveUsers)
	fmt.Printf("- Avg content length: %.2f characters\n", stats.AvgContentLength)

	fmt.Println("\n===== CLEANUP OPERATIONS =====")
	// Delete post
	if err := postRepo.Delete(updatedPost.ID); err != nil {
		log.Fatal("Failed to delete post:", err)
	}
	fmt.Printf("Deleted post ID=%d\n", updatedPost.ID)

	// Delete user
	if err := userRepo.Delete(createdUser.ID); err != nil {
		log.Fatal("Failed to delete user:", err)
	}
	fmt.Printf("Deleted user ID=%d\n", createdUser.ID)

	// Verify deletion
	_, err = userRepo.GetByID(createdUser.ID)
	if err == nil {
		fmt.Println("User still exists after deletion!")
	} else {
		fmt.Println("User successfully deleted (verification error expected):", err)
	}
}

// Helper functions for pointers
func ptrString(s string) *string {
	return &s
}

func ptrBool(b bool) *bool {
	return &b
}
