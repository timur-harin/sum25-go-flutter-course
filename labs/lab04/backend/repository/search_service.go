package repository

import (
	"context"
	"database/sql"

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

// TODO: Implement SearchPosts method using Squirrel query builder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	query := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").From("posts")

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
		query = query.Where("LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) + 1 >= ?", *filters.MinWordCount)
	}

	// Validate and set order by
	orderBy := "created_at"
	if filters.OrderBy == "title" || filters.OrderBy == "updated_at" {
		orderBy = filters.OrderBy
	}
	orderDir := "DESC"
	if filters.OrderDir == "ASC" {
		orderDir = "ASC"
	}
	query = query.OrderBy(orderBy + " " + orderDir)

	limit := 50
	if filters.Limit > 0 {
		limit = filters.Limit
	}
	query = query.Limit(uint64(limit))
	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}
	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sqlStr, args...)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// TODO: Implement SearchUsers method using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").From("users")
	if nameQuery != "" {
		query = query.Where(squirrel.Like{"name": "%" + nameQuery + "%"})
	}
	query = query.OrderBy("name").Limit(uint64(limit))
	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}
	var users []models.User
	err = sqlscan.Select(ctx, s.db, &users, sqlStr, args...)
	if err != nil {
		return nil, err
	}
	return users, nil
}

// TODO: Implement GetPostStats method using Squirrel with JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(p.id) as total_posts",
		"COUNT(CASE WHEN p.published = true THEN 1 END) as published_posts",
		"COUNT(DISTINCT p.user_id) as active_users",
		"AVG(LENGTH(p.content)) as avg_content_length",
	).From("posts p").Join("users u ON p.user_id = u.id")
	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}
	var stats PostStats
	err = sqlscan.Get(ctx, s.db, &stats, sqlStr, args...)
	if err != nil {
		return nil, err
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
		query = query.Where("LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) + 1 >= ?", *filters.MinWordCount)
	}
	return query
}

// TODO: Implement GetTopUsers method using Squirrel with complex aggregation
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
	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}
	var users []UserWithStats
	err = sqlscan.Select(ctx, s.db, &users, sqlStr, args...)
	if err != nil {
		return nil, err
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
