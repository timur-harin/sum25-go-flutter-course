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
	defer database.CloseDB(db)

	// Run migrations (using goose-based approach)
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create repository instances
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)
	searchService := repository.NewSearchService(db)

	// Demo operations
	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)
	fmt.Printf("Search service: %T\n", searchService)

	// Demo: Create a user
	fmt.Println("\n=== Creating User ===")
	userReq := &models.CreateUserRequest{
		Name:  "John Doe",
		Email: "john@example.com",
	}
	user, err := userRepo.Create(userReq)
	if err != nil {
		log.Printf("Failed to create user: %v", err)
	} else {
		fmt.Printf("Created user: ID=%d, Name=%s, Email=%s\n", user.ID, user.Name, user.Email)
	}

	// Demo: Create another user
	userReq2 := &models.CreateUserRequest{
		Name:  "Jane Smith",
		Email: "jane@example.com",
	}
	user2, err := userRepo.Create(userReq2)
	if err != nil {
		log.Printf("Failed to create second user: %v", err)
	} else {
		fmt.Printf("Created user: ID=%d, Name=%s, Email=%s\n", user2.ID, user2.Name, user2.Email)
	}

	// Demo: Get user by ID
	fmt.Println("\n=== Getting User by ID ===")
	if user != nil {
		foundUser, err := userRepo.GetByID(user.ID)
		if err != nil {
			log.Printf("Failed to get user by ID: %v", err)
		} else {
			fmt.Printf("Found user: ID=%d, Name=%s, Email=%s\n", foundUser.ID, foundUser.Name, foundUser.Email)
		}
	}

	// Demo: Get user by email
	fmt.Println("\n=== Getting User by Email ===")
	if user != nil {
		foundUser, err := userRepo.GetByEmail(user.Email)
		if err != nil {
			log.Printf("Failed to get user by email: %v", err)
		} else {
			fmt.Printf("Found user by email: ID=%d, Name=%s, Email=%s\n", foundUser.ID, foundUser.Name, foundUser.Email)
		}
	}

	// Demo: Get all users
	fmt.Println("\n=== Getting All Users ===")
	users, err := userRepo.GetAll()
	if err != nil {
		log.Printf("Failed to get all users: %v", err)
	} else {
		fmt.Printf("Total users: %d\n", len(users))
		for _, u := range users {
			fmt.Printf("  - ID=%d, Name=%s, Email=%s\n", u.ID, u.Name, u.Email)
		}
	}

	// Demo: Create a post
	fmt.Println("\n=== Creating Post ===")
	if user != nil {
		postReq := &models.CreatePostRequest{
			UserID:    user.ID,
			Title:     "My First Post",
			Content:   "This is the content of my first post. It's quite interesting!",
			Published: true,
		}
		post, err := postRepo.Create(postReq)
		if err != nil {
			log.Printf("Failed to create post: %v", err)
		} else {
			fmt.Printf("Created post: ID=%d, Title=%s, UserID=%d\n", post.ID, post.Title, post.UserID)
		}

		// Demo: Create another post
		postReq2 := &models.CreatePostRequest{
			UserID:    user.ID,
			Title:     "My Second Post",
			Content:   "This is another post with different content.",
			Published: false,
		}
		post2, err := postRepo.Create(postReq2)
		if err != nil {
			log.Printf("Failed to create second post: %v", err)
		} else {
			fmt.Printf("Created post: ID=%d, Title=%s, UserID=%d\n", post2.ID, post2.Title, post2.UserID)
		}

		// Demo: Get posts by user ID
		fmt.Println("\n=== Getting Posts by User ID ===")
		userPosts, err := postRepo.GetByUserID(user.ID)
		if err != nil {
			log.Printf("Failed to get posts by user ID: %v", err)
		} else {
			fmt.Printf("Posts for user %d: %d posts\n", user.ID, len(userPosts))
			for _, p := range userPosts {
				fmt.Printf("  - ID=%d, Title=%s, Published=%t\n", p.ID, p.Title, p.Published)
			}
		}

		// Demo: Get published posts
		fmt.Println("\n=== Getting Published Posts ===")
		publishedPosts, err := postRepo.GetPublished()
		if err != nil {
			log.Printf("Failed to get published posts: %v", err)
		} else {
			fmt.Printf("Published posts: %d posts\n", len(publishedPosts))
			for _, p := range publishedPosts {
				fmt.Printf("  - ID=%d, Title=%s, UserID=%d\n", p.ID, p.Title, p.UserID)
			}
		}

		// Demo: Search posts
		fmt.Println("\n=== Searching Posts ===")
		filters := repository.SearchFilters{
			Query:     "first",
			Published: &[]bool{true}[0],
			Limit:     10,
		}
		searchResults, err := searchService.SearchPosts(context.Background(), filters)
		if err != nil {
			log.Printf("Failed to search posts: %v", err)
		} else {
			fmt.Printf("Search results for 'first': %d posts\n", len(searchResults))
			for _, p := range searchResults {
				fmt.Printf("  - ID=%d, Title=%s, UserID=%d\n", p.ID, p.Title, p.UserID)
			}
		}

		// Demo: Get post statistics
		fmt.Println("\n=== Getting Post Statistics ===")
		stats, err := searchService.GetPostStats(context.Background())
		if err != nil {
			log.Printf("Failed to get post stats: %v", err)
		} else {
			fmt.Printf("Post Statistics:\n")
			fmt.Printf("  - Total posts: %d\n", stats.TotalPosts)
			fmt.Printf("  - Published posts: %d\n", stats.PublishedPosts)
			fmt.Printf("  - Active users: %d\n", stats.ActiveUsers)
			fmt.Printf("  - Average content length: %.2f\n", stats.AvgContentLength)
		}

		// Demo: Get top users
		fmt.Println("\n=== Getting Top Users ===")
		topUsers, err := searchService.GetTopUsers(context.Background(), 5)
		if err != nil {
			log.Printf("Failed to get top users: %v", err)
		} else {
			fmt.Printf("Top users:\n")
			for _, u := range topUsers {
				fmt.Printf("  - %s (%s): %d posts (%d published)\n", u.Name, u.Email, u.PostCount, u.PublishedCount)
			}
		}
	}

	// Demo: Count operations
	fmt.Println("\n=== Counting Operations ===")
	userCount, err := userRepo.Count()
	if err != nil {
		log.Printf("Failed to count users: %v", err)
	} else {
		fmt.Printf("Total users: %d\n", userCount)
	}

	postCount, err := postRepo.Count()
	if err != nil {
		log.Printf("Failed to count posts: %v", err)
	} else {
		fmt.Printf("Total posts: %d\n", postCount)
	}

	if user != nil {
		userPostCount, err := postRepo.CountByUserID(user.ID)
		if err != nil {
			log.Printf("Failed to count posts by user: %v", err)
		} else {
			fmt.Printf("Posts by user %d: %d\n", user.ID, userPostCount)
		}
	}

	fmt.Println("\n=== Demo completed successfully! ===")
}
