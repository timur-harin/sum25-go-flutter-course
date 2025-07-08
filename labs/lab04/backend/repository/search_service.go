package repository

import (
	"context"
	"database/sql"
	"fmt"

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
	Query        string
	UserID       *int
	Published    *bool
	MinWordCount *int
	Limit        int
	Offset       int
	OrderBy      string
	OrderDir     string
}

// NewSearchService creates a new SearchService
func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar),
	}
}

// SearchPosts executes a dynamic query for posts using Squirrel
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	query := s.psql.
		Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	// Dynamic filters
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.ILike{"title": searchTerm},
			squirrel.ILike{"content": searchTerm},
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.MinWordCount != nil {
		query = query.Where("length(content) - length(replace(content, ' ', '')) + 1 >= ?", *filters.MinWordCount)
	}

	// Validate and add ORDER BY
	switch filters.OrderBy {
	case "title", "created_at", "updated_at":
		order := "ASC"
		if filters.OrderDir == "DESC" {
			order = "DESC"
		}
		query = query.OrderBy(fmt.Sprintf("%s %s", filters.OrderBy, order))
	}

	// Apply limit and offset
	if filters.Limit <= 0 {
		filters.Limit = 50
	}
	query = query.Limit(uint64(filters.Limit)).Offset(uint64(filters.Offset))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sqlStr, args...)
	return posts, err
}

// SearchUsers finds users by name using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.
		Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var users []models.User
	err = sqlscan.Select(ctx, s.db, &users, sqlStr, args...)
	return users, err
}

// GetPostStats computes post statistics using JOINs and Squirrel
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.
		Select(
			"COUNT(p.id) as total_posts",
			"COUNT(CASE WHEN p.published = true THEN 1 END) as published_posts",
			"COUNT(DISTINCT p.user_id) as active_users",
			"AVG(LENGTH(p.content)) as avg_content_length",
		).
		From("posts p").
		Join("users u ON p.user_id = u.id")

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var stats PostStats
	err = sqlscan.Get(ctx, s.db, &stats, sqlStr, args...)
	return &stats, err
}

// BuildDynamicQuery builds a filtered post query using Squirrel
func (s *SearchService) BuildDynamicQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		baseQuery = baseQuery.Where(squirrel.Or{
			squirrel.ILike{"title": searchTerm},
			squirrel.ILike{"content": searchTerm},
		})
	}

	if filters.UserID != nil {
		baseQuery = baseQuery.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		baseQuery = baseQuery.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.MinWordCount != nil {
		baseQuery = baseQuery.Where("length(content) - length(replace(content, ' ', '')) + 1 >= ?", *filters.MinWordCount)
	}

	return baseQuery
}

// GetTopUsers gets users with aggregated post stats using Squirrel
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	query := s.psql.
		Select(
			"u.id",
			"u.name",
			"u.email",
			"COUNT(p.id) as post_count",
			"COUNT(CASE WHEN p.published = true THEN 1 END) as published_count",
			"MAX(p.created_at) as last_post_date",
		).
		From("users u").
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
	return users, err
}

// PostStats represents aggregated post statistics
type PostStats struct {
	TotalPosts       int     `db:"total_posts"`
	PublishedPosts   int     `db:"published_posts"`
	ActiveUsers      int     `db:"active_users"`
	AvgContentLength float64 `db:"avg_content_length"`
}

// UserWithStats represents a user with post statistics
type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}
