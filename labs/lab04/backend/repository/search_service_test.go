package repository

import (
	"context"
	"testing"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/stretchr/testify/assert"
	"lab04-backend/database"
	_ "lab04-backend/models"
)

// TestSearchService tests the Squirrel query builder approach
func TestSearchService(t *testing.T) {
	// Initialize database for testing
	db, err := database.InitDB()
	if err != nil {
		t.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB(db)

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		t.Fatalf("Failed to run migrations: %v", err)
	}

	// Create service instance
	searchService := NewSearchService(db)

	// TODO: Test SearchPosts with various filters
	t.Run("SearchPosts with filters", func(t *testing.T) {
		_, err := db.Exec(`
			INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
			VALUES 
				(1, 'Go Programming', 'Content about Golang', true, NOW(), NOW()),
				(1, 'Advanced Go', 'More Golang content', true, NOW(), NOW()),
				(2, 'Python Basics', 'Python tutorial', false, NOW(), NOW())
		`)
		assert.NoError(t, err)

		// Test 1: Empty filters
		posts, err := searchService.SearchPosts(context.Background(), SearchFilters{Limit: 10})
		assert.NoError(t, err)
		assert.Len(t, posts, 3)

		// Test 2: Query filter
		posts, err = searchService.SearchPosts(context.Background(), SearchFilters{
			Query:   "golang",
			Limit:   10,
			OrderBy: "title",
		})
		assert.NoError(t, err)
		assert.Len(t, posts, 2)
		assert.Equal(t, "Advanced Go", posts[0].Title)

		// Test 3: Published filter
		published := true
		posts, err = searchService.SearchPosts(context.Background(), SearchFilters{
			Published: &published,
			Limit:     10,
		})
		assert.NoError(t, err)
		assert.Len(t, posts, 2)

		// Test 4: User ID filter
		userID := 2
		posts, err = searchService.SearchPosts(context.Background(), SearchFilters{
			UserID: &userID,
			Limit:  10,
		})
		assert.NoError(t, err)
		assert.Len(t, posts, 1)
		assert.Equal(t, "Python Basics", posts[0].Title)
	})

	// TODO: Test SearchUsers functionality
	t.Run("SearchUsers", func(t *testing.T) {
		// Insert test data
		_, err := db.Exec(`
			INSERT INTO users (name, email, created_at, updated_at)
			VALUES 
				('John Doe', 'john@example.com', NOW(), NOW()),
				('Jane Smith', 'jane@example.com', NOW(), NOW())
		`)
		assert.NoError(t, err)

		// Test 1: Empty query
		users, err := searchService.SearchUsers(context.Background(), "", 10)
		assert.NoError(t, err)
		assert.Len(t, users, 2)

		// Test 2: Partial match
		users, err = searchService.SearchUsers(context.Background(), "Jane", 10)
		assert.NoError(t, err)
		assert.Len(t, users, 1)
		assert.Equal(t, "Jane Smith", users[0].Name)

		// Test 3: Case insensitive
		users, err = searchService.SearchUsers(context.Background(), "jOh", 10)
		assert.NoError(t, err)
		assert.Len(t, users, 1)
		assert.Equal(t, "John Doe", users[0].Name)

		// Test 4: Limit
		users, err = searchService.SearchUsers(context.Background(), "e", 1)
		assert.NoError(t, err)
		assert.Len(t, users, 1)
	})

	// TODO: Test GetPostStats with complex aggregation
	t.Run("GetPostStats", func(t *testing.T) {
		// Clear tables
		_, err := db.Exec("DELETE FROM posts")
		assert.NoError(t, err)
		_, err = db.Exec("DELETE FROM users")
		assert.NoError(t, err)

		// Insert test data
		_, err = db.Exec(`
			INSERT INTO users (id, name, email) VALUES 
				(1, 'User1', 'user1@test.com'),
				(2, 'User2', 'user2@test.com')
		`)
		assert.NoError(t, err)

		_, err = db.Exec(`
			INSERT INTO posts (user_id, title, content, published) VALUES 
				(1, 'Post1', 'Short content', true),
				(1, 'Post2', 'Medium length content', true),
				(1, 'Post3', 'Longer content example', false),
				(2, 'Post4', 'Content', true)
		`)
		assert.NoError(t, err)

		// Get stats
		stats, err := searchService.GetPostStats(context.Background())
		assert.NoError(t, err)
		assert.Equal(t, 4, stats.TotalPosts)
		assert.Equal(t, 3, stats.PublishedPosts)
		assert.Equal(t, 2, stats.ActiveUsers)
		assert.InDelta(t, 15.25, stats.AvgContentLength, 0.01)
	})

	// TODO: Test GetTopUsers with aggregation and sorting
	t.Run("GetTopUsers", func(t *testing.T) {
		// Clear tables
		_, err := db.Exec("DELETE FROM posts")
		assert.NoError(t, err)
		_, err = db.Exec("DELETE FROM users")
		assert.NoError(t, err)

		// Insert test data
		_, err = db.Exec(`
			INSERT INTO users (id, name, email) VALUES 
				(1, 'Active User', 'active@test.com'),
				(2, 'Inactive User', 'inactive@test.com')
		`)
		assert.NoError(t, err)

		_, err = db.Exec(`
			INSERT INTO posts (user_id, title, content, published, created_at) VALUES 
				(1, 'Post1', 'Content', true, NOW() - INTERVAL '2 days'),
				(1, 'Post2', 'Content', true, NOW() - INTERVAL '1 day'),
				(1, 'Post3', 'Content', false, NOW()),
				(2, 'Post4', 'Content', true, NOW())
		`)
		assert.NoError(t, err)

		// Get top users
		users, err := searchService.GetTopUsers(context.Background(), 2)
		assert.NoError(t, err)
		assert.Len(t, users, 2)

		// Verify top user
		assert.Equal(t, "Active User", users[0].Name)
		assert.Equal(t, 3, users[0].PostCount)
		assert.Equal(t, 2, users[0].PublishedCount)
		assert.NotEmpty(t, users[0].LastPostDate)

		// Verify second user
		assert.Equal(t, "Inactive User", users[1].Name)
		assert.Equal(t, 1, users[1].PostCount)
	})

	// TODO: Test BuildDynamicQuery helper
	t.Run("BuildDynamicQuery", func(t *testing.T) {
		baseQuery := searchService.psql.Select("*").From("posts")

		// Test with filters
		published := true
		filters := SearchFilters{
			Query:        "test",
			UserID:       ptrInt(1),
			Published:    &published,
			MinWordCount: ptrInt(100),
		}

		query := searchService.BuildDynamicQuery(baseQuery, filters)
		sql, args, err := query.ToSql()

		assert.NoError(t, err)
		assert.Contains(t, sql, "WHERE")
		assert.Contains(t, sql, "title ILIKE")
		assert.Contains(t, sql, "user_id =")
		assert.Contains(t, sql, "published =")
		assert.Contains(t, sql, "array_length")
		assert.Len(t, args, 4)
	})
}

// Helper function for pointer to int
func ptrInt(i int) *int {
	return &i
}

// TestSquirrelQueryBuilder tests Squirrel query building functionality
func TestSquirrelQueryBuilder(t *testing.T) {
	// TODO: Test Squirrel query builder patterns
	t.Run("Basic Query Building", func(t *testing.T) {
		psql := squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar)
		query := psql.Select("id", "name").
			From("users").
			Where(squirrel.Eq{"active": true}).
			OrderBy("name DESC").
			Limit(10).
			Offset(5)

		sql, args, err := query.ToSql()
		assert.NoError(t, err)
		expectedSQL := "SELECT id, name FROM users WHERE active = $1 ORDER BY name DESC LIMIT 10 OFFSET 5"
		assert.Equal(t, expectedSQL, sql)
		assert.Equal(t, []interface{}{true}, args)
	})

	t.Run("Complex Query Building", func(t *testing.T) {
		psql := squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar)

		// Create subquery
		subquery := psql.Select("user_id").
			From("posts").
			Where(squirrel.Gt{"created_at": time.Now().AddDate(0, 0, -7)}).
			GroupBy("user_id").
			Having("COUNT(*) > 5")

		// Main query with JOIN, subquery, and complex conditions
		query := psql.Select("u.id", "u.name", "COUNT(p.id) AS post_count").
			From("users u").
			LeftJoin("posts p ON u.id = p.user_id").
			Where(squirrel.And{
				squirrel.Or{
					squirrel.Eq{"u.active": true},
					squirrel.Like{"u.name": "%admin%"},
				},
				squirrel.NotEq{"u.role": "banned"},
				squirrel.Expr("u.id IN (?)", subquery),
			}).
			GroupBy("u.id", "u.name").
			Having("COUNT(p.id) > ?", 5).
			OrderBy("post_count DESC")

		sql, args, err := query.ToSql()

		assert.NoError(t, err)
		expectedSQL := "SELECT u.id, u.name, COUNT(p.id) AS post_count FROM users u " +
			"LEFT JOIN posts p ON u.id = p.user_id " +
			"WHERE ((u.active = $1 OR u.name LIKE $2) AND u.role <> $3 AND u.id IN (SELECT user_id FROM posts WHERE created_at > $4 GROUP BY user_id HAVING COUNT(*) > $5)) " +
			"GROUP BY u.id, u.name HAVING COUNT(p.id) > $6 " +
			"ORDER BY post_count DESC"
		assert.Equal(t, expectedSQL, sql)
		assert.Len(t, args, 6)
	})
}

// BenchmarkSquirrelVsManualSQL benchmarks Squirrel vs manual SQL building
func BenchmarkSquirrelVsManualSQL(b *testing.B) {
	// TODO: Compare performance of Squirrel vs manual string building
	b.Run("Squirrel", func(b *testing.B) {
		// TODO: Benchmark Squirrel query building
		b.Skip("TODO: implement Squirrel benchmark")
	})

	b.Run("Manual SQL", func(b *testing.B) {
		// TODO: Benchmark manual string building
		b.Skip("TODO: implement manual SQL benchmark")
	})
}
