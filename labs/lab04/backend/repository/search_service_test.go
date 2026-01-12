package repository

import (
	"context"
	"database/sql"
	"os"
	"testing"
	"time"

	"lab04-backend/database"
	"lab04-backend/models"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// setupSearchTestDB creates a fresh DB for search tests
func setupSearchTestDB(t *testing.T) (*sql.DB, *SearchService) {
	dbPath := "./test_search.db"
	_ = os.Remove(dbPath)

	config := database.DefaultConfig()
	config.DatabasePath = dbPath
	db, err := database.InitDBWithConfig(config)
	require.NoError(t, err, "Failed to initialize database")

	err = database.RunMigrations(db)
	require.NoError(t, err, "Failed to run migrations")

	searchService := NewSearchService(db)

	return db, searchService
}

func seedData(t *testing.T, db *sql.DB) (*models.User, *models.User) {
	userRepo := NewUserRepository(db)

	user1Req := &models.CreateUserRequest{Name: "Alice", Email: "alice@example.com"}
	user1, err := userRepo.Create(user1Req)
	require.NoError(t, err)

	user2Req := &models.CreateUserRequest{Name: "Bob", Email: "bob@example.com"}
	user2, err := userRepo.Create(user2Req)
	require.NoError(t, err)

	postRepo := NewPostRepository(db)
	_, _ = postRepo.Create(&models.CreatePostRequest{UserID: user1.ID, Title: "Intro to Golang", Content: "Golang is fun.", Published: true})
	time.Sleep(10 * time.Millisecond)
	_, _ = postRepo.Create(&models.CreatePostRequest{UserID: user1.ID, Title: "Advanced Golang", Content: "Concurrency in Go.", Published: true})
	time.Sleep(10 * time.Millisecond)
	_, _ = postRepo.Create(&models.CreatePostRequest{UserID: user2.ID, Title: "Python for Beginners", Content: "Learn Python basics.", Published: true})
	time.Sleep(10 * time.Millisecond)
	_, _ = postRepo.Create(&models.CreatePostRequest{UserID: user2.ID, Title: "Python vs. Golang", Content: "A comparison.", Published: false})

	return user1, user2
}

func TestSearchService(t *testing.T) {
	db, searchService := setupSearchTestDB(t)
	defer db.Close()
	defer os.Remove("./test_search.db")

	user1, _ := seedData(t, db)

	t.Run("SearchPosts", func(t *testing.T) {
		ctx := context.Background()

		// Test no filters
		posts, err := searchService.SearchPosts(ctx, SearchFilters{})
		assert.NoError(t, err)
		assert.Len(t, posts, 4)

		// Test search by query
		posts, err = searchService.SearchPosts(ctx, SearchFilters{Query: "golang"})
		assert.NoError(t, err)
		assert.Len(t, posts, 3)

		// Test search by query and published status
		posts, err = searchService.SearchPosts(ctx, SearchFilters{Query: "golang", Published: boolPtr(true)})
		assert.NoError(t, err)
		assert.Len(t, posts, 2)

		// Test filter by user ID
		posts, err = searchService.SearchPosts(ctx, SearchFilters{UserID: &user1.ID})
		assert.NoError(t, err)
		assert.Len(t, posts, 2)
		assert.Equal(t, "Advanced Golang", posts[0].Title)

		// Test pagination
		posts, err = searchService.SearchPosts(ctx, SearchFilters{Limit: 1, Offset: 1})
		assert.NoError(t, err)
		assert.Len(t, posts, 1)
		assert.Equal(t, "Python for Beginners", posts[0].Title) // Ordered by created_at DESC

		// Test ordering
		posts, err = searchService.SearchPosts(ctx, SearchFilters{OrderBy: "title", OrderDir: "ASC"})
		assert.NoError(t, err)
		assert.Len(t, posts, 4)
		assert.Equal(t, "Advanced Golang", posts[0].Title)
	})

	t.Run("SearchUsers", func(t *testing.T) {
		ctx := context.Background()
		users, err := searchService.SearchUsers(ctx, "ali", 10)
		assert.NoError(t, err)
		assert.Len(t, users, 1)
		assert.Equal(t, "Alice", users[0].Name)
	})

	t.Run("GetPostStats", func(t *testing.T) {
		ctx := context.Background()
		stats, err := searchService.GetPostStats(ctx)
		assert.NoError(t, err)
		assert.Equal(t, 4, stats.TotalPosts)
		assert.Equal(t, 3, stats.PublishedPosts)
		assert.Equal(t, 2, stats.ActiveUsers)
		assert.True(t, stats.AvgContentLength > 0)

		// Test with no data
		_, _ = db.Exec("DELETE FROM posts")
		stats, err = searchService.GetPostStats(ctx)
		assert.NoError(t, err)
		assert.Equal(t, 0, stats.TotalPosts)
	})

	t.Run("GetTopUsers", func(t *testing.T) {
		_, _ = db.Exec("DELETE FROM posts")
		_, _ = db.Exec("DELETE FROM users")
		user1, user2 := seedData(t, db)
		userRepo := NewUserRepository(db)
		user3, _ := userRepo.Create(&models.CreateUserRequest{Name: "Charlie", Email: "charlie@example.com"})
		ctx := context.Background()
		topUsers, err := searchService.GetTopUsers(ctx, 10)
		assert.NoError(t, err)
		require.Len(t, topUsers, 3)
		foundAlice := false
		foundBob := false

		for _, topUser := range topUsers {
			if topUser.Name == user1.Name { // Alice
				foundAlice = true
				assert.Equal(t, 2, topUser.PostCount)
				assert.Equal(t, 2, topUser.PublishedCount)
			}
			if topUser.Name == user2.Name { // Bob
				foundBob = true
				assert.Equal(t, 2, topUser.PostCount)
				assert.Equal(t, 1, topUser.PublishedCount)
			}
		}
		assert.True(t, foundAlice, "Alice should be in top users")
		assert.True(t, foundBob, "Bob should be in top users")

		assert.Equal(t, user3.Name, topUsers[2].Name)
		assert.Equal(t, 0, topUsers[2].PostCount)
		assert.False(t, topUsers[2].LastPostDate.Valid)
	})
}

func boolPtr(b bool) *bool {
	return &b
}
