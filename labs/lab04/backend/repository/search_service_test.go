package repository

import (
	"context"
	"testing"
	"time"

	"lab04-backend/database"
)

func TestSearchService(t *testing.T) {
	db, err := database.InitDB()
	if err != nil {
		t.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB(db)

	if err := database.RunMigrations(db); err != nil {
		t.Fatalf("Failed to run migrations: %v", err)
	}

	searchService := NewSearchService(db)

	t.Run("SearchPosts with filters", func(t *testing.T) {
		// Очистим и подготовим данные
		_, err := db.Exec("DELETE FROM posts")
		if err != nil {
			t.Fatalf("Failed to clean posts table: %v", err)
		}

		now := time.Now()
		_, err = db.Exec(`
			INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6),
				   ($7, $8, $9, $10, $11, $12),
				   ($13, $14, $15, $16, $17, $18)
		`,
			1, "Golang post", "Content 1", true, now, now,
			2, "Python post", "Content 2", false, now, now,
			1, "Another Golang post", "Content 3", true, now, now,
		)
		if err != nil {
			t.Fatalf("Failed to insert test posts: %v", err)
		}

		// Пустой фильтр - должны получить все
		posts, err := searchService.SearchPosts(context.Background(), SearchFilters{})
		if err != nil {
			t.Fatalf("SearchPosts failed: %v", err)
		}
		if len(posts) != 3 {
			t.Errorf("expected 3 posts, got %d", len(posts))
		}

		// Поиск по строке
		posts, err = searchService.SearchPosts(context.Background(), SearchFilters{Query: "Golang"})
		if err != nil {
			t.Fatalf("SearchPosts failed: %v", err)
		}
		if len(posts) != 2 {
			t.Errorf("expected 2 posts with 'Golang', got %d", len(posts))
		}
	})

	t.Run("SearchUsers", func(t *testing.T) {
		// Очистка и подготовка тестовых данных
		_, err := db.Exec("DELETE FROM users")
		if err != nil {
			t.Fatalf("Failed to clean users table: %v", err)
		}

		now := time.Now()
		_, err = db.Exec(`
			INSERT INTO users (name, email, created_at, updated_at)
			VALUES ($1, $2, $3, $4),
				   ($5, $6, $7, $8),
				   ($9, $10, $11, $12)
		`,
			"Alice", "alice@example.com", now, now,
			"Bob", "bob@example.com", now, now,
			"Alicia", "alicia@example.com", now, now,
		)
		if err != nil {
			t.Fatalf("Failed to insert test users: %v", err)
		}

		users, err := searchService.SearchUsers(context.Background(), "Ali", 10)
		if err != nil {
			t.Fatalf("SearchUsers failed: %v", err)
		}
		if len(users) != 2 {
			t.Errorf("expected 2 users matching 'Ali', got %d", len(users))
		}
	})

	t.Run("GetPostStats", func(t *testing.T) {
		err := database.RunMigrations(db)
		if err != nil {
			t.Fatalf("Failed to run migrations: %v", err)
		}

		stats, err := searchService.GetPostStats(context.Background())
		if err != nil {
			t.Fatalf("GetPostStats failed: %v", err)
		}
		if stats == nil {
			t.Error("expected non-nil stats result")
		}
	})

	t.Run("GetTopUsers", func(t *testing.T) {
		topUsers, err := searchService.GetTopUsers(context.Background(), 5)
		if err != nil {
			t.Fatalf("GetTopUsers failed: %v", err)
		}
		if len(topUsers) > 5 {
			t.Errorf("expected at most 5 top users, got %d", len(topUsers))
		}
	})

	t.Run("BuildDynamicQuery", func(t *testing.T) {
		baseQuery := searchService.psql.Select("*").From("posts")
		filters := SearchFilters{Query: "test", Published: &[]bool{true}[0]}
		query := searchService.BuildDynamicQuery(baseQuery, filters)
		sql, args, err := query.ToSql()
		if err != nil {
			t.Fatalf("BuildDynamicQuery ToSql failed: %v", err)
		}
		if sql == "" {
			t.Error("generated SQL is empty")
		}
		if len(args) == 0 {
			t.Error("expected arguments in query")
		}
	})
}
