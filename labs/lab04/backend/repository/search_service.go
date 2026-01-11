package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/v2/sqlscan"
	"lab04-backend/models"
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

// TODO: Implement SearchPosts method using Squirrel query builder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	// Base query
	query := s.psql.Select(
		"id", "user_id", "title", "content", "published",
		"created_at", "updated_at",
	).From("posts")

	// Apply dynamic filters
	query = s.BuildDynamicQuery(query, filters)

	// Apply ordering
	if filters.OrderBy != "" {
		orderDir := "ASC"
		if strings.ToUpper(filters.OrderDir) == "DESC" {
			orderDir = "DESC"
		}
		query = query.OrderBy(fmt.Sprintf("%s %s", filters.OrderBy, orderDir))
	} else {
		query = query.OrderBy("created_at DESC")
	}

	// Apply pagination
	if filters.Limit <= 0 {
		filters.Limit = 50 // Default limit
	}
	query = query.Limit(uint64(filters.Limit)).Offset(uint64(filters.Offset))

	// Build SQL
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	// Execute query
	var posts []models.Post
	if err := sqlscan.Select(ctx, s.db, &posts, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	return posts, nil
}

// TODO: Implement SearchUsers method using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	// Build base query
	query := s.psql.Select(
		"id", "name", "email", "created_at", "updated_at",
	).From("users")

	// Apply search filter
	if nameQuery != "" {
		query = query.Where(squirrel.ILike{"name": "%" + nameQuery + "%"})
	}

	// Apply ordering and limit
	query = query.OrderBy("name ASC").Limit(uint64(limit))

	// Build SQL
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	// Execute query
	var users []models.User
	if err := sqlscan.Select(ctx, s.db, &users, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	return users, nil
}

// TODO: Implement GetPostStats method using Squirrel with JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	// Build stats query
	query := s.psql.Select(
		"COUNT(id) AS total_posts",
		"COUNT(CASE WHEN published = true THEN 1 END) AS published_posts",
		"COUNT(DISTINCT user_id) AS active_users",
		"COALESCE(AVG(LENGTH(content)), 0) AS avg_content_length",
	).From("posts")

	// Build SQL
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	// Execute query
	var stats PostStats
	if err := sqlscan.Get(ctx, s.db, &stats, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
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

// TODO: Implement BuildDynamicQuery helper method
func (s *SearchService) BuildDynamicQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	query := baseQuery

	// Search query filter
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.ILike{"title": searchTerm},
			squirrel.ILike{"content": searchTerm},
		})
	}

	// User ID filter
	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	// Published status filter
	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	// Min word count filter
	if filters.MinWordCount != nil {
		query = query.Where(
			"array_length(regexp_split_to_array(content, '\\s+'), 1) >= ?",
			*filters.MinWordCount,
		)
	}

	return query
}

// TODO: Implement GetTopUsers method using Squirrel with complex aggregation
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	// Build complex aggregation query
	query := s.psql.Select(
		"u.id",
		"u.name",
		"u.email",
		"COUNT(p.id) AS post_count",
		"COUNT(CASE WHEN p.published = true THEN 1 END) AS published_count",
		"MAX(p.created_at) AS last_post_date",
	).From("users u").
		LeftJoin("posts p ON u.id = p.user_id").
		GroupBy("u.id", "u.name", "u.email").
		OrderBy("post_count DESC").
		Limit(uint64(limit))

	// Build SQL
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	// Execute query
	var users []UserWithStats
	if err := sqlscan.Select(ctx, s.db, &users, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
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
