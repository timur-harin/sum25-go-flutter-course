package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
)

// SearchService handles dynamic search operations using Squirrel query builder
// This service demonstrates SQUIRREL QUERY BUILDER approach for dynamic SQL
type SearchService struct {
	db   *sql.DB
	psql squirrel.StatementBuilderType
}

// SearchFilters represents search parameters
type SearchFilters struct {
	Query        string // Search in title and content
	UserID       *int   // Filter by user ID
	Published    *bool  // Filter by published status
	MinWordCount *int   // Minimum word count in content
	Limit        int    // Results limit (default 50)
	Offset       int    // Results offset (for pagination)
	OrderBy      string // Order by field (title, created_at, updated_at)
	OrderDir     string // Order direction (ASC, DESC)
}

// NewSearchService creates a new SearchService
func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar),
	}
}

// SearchPosts method using Squirrel query builder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	// Build base query
	query := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	// Add WHERE conditions dynamically
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.Like{"title": searchTerm},
			squirrel.Like{"content": searchTerm},
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.MinWordCount != nil {
		// Simple word count approximation using space count
		query = query.Where("LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) >= ?", *filters.MinWordCount-1)
	}

	// Add ORDER BY dynamically
	if filters.OrderBy != "" {
		validOrderFields := map[string]bool{
			"title":      true,
			"created_at": true,
			"updated_at": true,
		}
		if validOrderFields[filters.OrderBy] {
			orderDir := "ASC"
			if strings.ToUpper(filters.OrderDir) == "DESC" {
				orderDir = "DESC"
			}
			query = query.OrderBy(filters.OrderBy + " " + orderDir)
		}
	}

	// Add LIMIT/OFFSET
	if filters.Limit > 0 {
		query = query.Limit(uint64(filters.Limit))
	} else {
		query = query.Limit(50) // Default limit
	}

	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	// Build final SQL
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	// Execute query
	rows, err := s.db.QueryContext(ctx, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	// Scan results manually since we don't have scany
	var posts []models.Post
	for rows.Next() {
		var post models.Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		posts = append(posts, post)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return posts, nil
}

// SearchUsers method using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	rows, err := s.db.QueryContext(ctx, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		users = append(users, user)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return users, nil
}

// GetPostStats method using Squirrel with JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(p.id) as total_posts",
		"COUNT(CASE WHEN p.published = true THEN 1 END) as published_posts",
		"COUNT(DISTINCT p.user_id) as active_users",
		"AVG(LENGTH(p.content)) as avg_content_length",
	).From("posts p").
		LeftJoin("users u ON p.user_id = u.id")

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	row := s.db.QueryRowContext(ctx, sql, args...)
	var stats PostStats
	err = row.Scan(&stats.TotalPosts, &stats.PublishedPosts, &stats.ActiveUsers, &stats.AvgContentLength)
	if err != nil {
		return nil, fmt.Errorf("failed to scan stats: %w", err)
	}

	return &stats, nil
}

// PostStats represents aggregated post statistics
type PostStats struct {
	TotalPosts       int     `db:"total_posts"`
	PublishedPosts   int     `db:"published_posts"`
	ActiveUsers      int     `db:"active_users"`
	AvgContentLength float64 `db:"avg_content_length"`
}

// BuildDynamicQuery helper method
func (s *SearchService) BuildDynamicQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	query := baseQuery

	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.Like{"title": searchTerm},
			squirrel.Like{"content": searchTerm},
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.MinWordCount != nil {
		query = query.Where("LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) >= ?", *filters.MinWordCount-1)
	}

	return query
}

// GetTopUsers method using Squirrel with complex aggregation
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	query := s.psql.Select(
		"u.id",
		"u.name",
		"u.email",
		"COUNT(p.id) as post_count",
		"COUNT(CASE WHEN p.published = true THEN 1 END) as published_count",
		"MAX(p.created_at) as last_post_date",
	).From("users u").
		LeftJoin("posts p ON u.id = p.user_id").
		GroupBy("u.id", "u.name", "u.email").
		OrderBy("post_count DESC").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	rows, err := s.db.QueryContext(ctx, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	var users []UserWithStats
	for rows.Next() {
		var user UserWithStats
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.PostCount, &user.PublishedCount, &user.LastPostDate)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		users = append(users, user)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return users, nil
}

// UserWithStats represents a user with post statistics
type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}
