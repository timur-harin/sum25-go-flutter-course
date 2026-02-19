package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/v2/sqlscan"
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

// SearchPosts searches posts using Squirrel query builder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	// Start with base query
	query := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts").
		Where(squirrel.Eq{"deleted_at": nil})

	// Build dynamic query with filters
	query = s.BuildDynamicQuery(query, filters)

	// Add ORDER BY
	if filters.OrderBy != "" {
		orderBy := filters.OrderBy
		orderDir := "ASC"
		if filters.OrderDir != "" {
			orderDir = strings.ToUpper(filters.OrderDir)
		}
		query = query.OrderBy(fmt.Sprintf("%s %s", orderBy, orderDir))
	} else {
		query = query.OrderBy("created_at DESC")
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
		return nil, fmt.Errorf("failed to build SQL query: %v", err)
	}

	// Execute with scany
	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute search query: %v", err)
	}

	return posts, nil
}

// SearchUsers searches users using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Eq{"deleted_at": nil}).
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build user search SQL: %v", err)
	}

	var users []models.User
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute user search: %v", err)
	}

	return users, nil
}

// GetPostStats gets post statistics using Squirrel with JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(p.id) as total_posts",
		"COUNT(CASE WHEN p.published = 1 THEN 1 END) as published_posts",
		"COUNT(DISTINCT p.user_id) as active_users",
		"AVG(LENGTH(p.content)) as avg_content_length",
	).From("posts p").
		Join("users u ON p.user_id = u.id").
		Where(squirrel.Eq{"p.deleted_at": nil}).
		Where(squirrel.Eq{"u.deleted_at": nil})

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build stats SQL: %v", err)
	}

	var stats PostStats
	err = sqlscan.Get(ctx, s.db, &stats, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute stats query: %v", err)
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

// BuildDynamicQuery builds dynamic query with filters
func (s *SearchService) BuildDynamicQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	query := baseQuery

	// Add search query filter
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.Like{"title": searchTerm},
			squirrel.Like{"content": searchTerm},
		})
	}

	// Add user ID filter
	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	// Add published filter
	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	// Add minimum word count filter
	if filters.MinWordCount != nil {
		// Count words in content (simple approach)
		wordCountExpr := fmt.Sprintf("(LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) + 1) >= %d", *filters.MinWordCount)
		query = query.Where(wordCountExpr)
	}

	return query
}

// GetTopUsers gets top users with post statistics using Squirrel
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	query := s.psql.Select(
		"u.id",
		"u.name",
		"u.email",
		"u.created_at",
		"u.updated_at",
		"COUNT(p.id) as post_count",
		"COUNT(CASE WHEN p.published = 1 THEN 1 END) as published_count",
		"MAX(p.created_at) as last_post_date",
	).From("users u").
		LeftJoin("posts p ON u.id = p.user_id AND p.deleted_at IS NULL").
		Where(squirrel.Eq{"u.deleted_at": nil}).
		GroupBy("u.id", "u.name", "u.email", "u.created_at", "u.updated_at").
		OrderBy("post_count DESC").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build top users SQL: %v", err)
	}

	var users []UserWithStats
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute top users query: %v", err)
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
