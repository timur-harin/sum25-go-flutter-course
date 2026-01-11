package repository

import (
	"context"
	"database/sql"
	"strings"

	"github.com/georgysavva/scany/v2/sqlscan"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
)

// SearchService handles dynamic search operations using Squirrel qbbuilder
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

// TODO: Implement SearchPosts method using Squirrel qbbuilder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	qb := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	qb = s.BuildDynamicQuery(qb, filters)

	sqlStr, args, err := qb.ToSql()
	if err != nil {
		return nil, err
	}

	var posts []models.Post
	if err := sqlscan.Select(ctx, s.db, &posts, sqlStr, args...); err != nil {
		return nil, err
	}

	return posts, err
}

// TODO: Implement SearchUsers method using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	qb := s.psql.
		Select("id", "name", "email", "created_at", "updated_at").
		From("users")

	if nameQuery != "" {
		qb = qb.Where(squirrel.ILike{"name": "%" + nameQuery + "%"})
	}

	qb = qb.OrderBy("name ASC")

	if limit > 0 {
		qb = qb.Limit(uint64(limit))
	}

	sqlStr, args, err := qb.ToSql()
	if err != nil {
		return nil, err
	}

	var users []models.User
	if err := sqlscan.Select(ctx, s.db, &users, sqlStr, args...); err != nil {
		return nil, err
	}

	return users, nil
}

// TODO: Implement GetPostStats method using Squirrel with JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	// TODO: Build complex qbwith JOINs using Squirrel
	qb := s.psql.Select(
		"COUNT(p.id) as total_posts",
		"COUNT(CASE WHEN p.published = true THEN 1 END) as published_posts",
		"COUNT(DISTINCT p.user_id) as active_users",
		"AVG(LENGTH(p.content)) as avg_content_length",
	).From("posts p").
		Join("users u ON p.user_id = u.id")

	sqlStr, args, err := qb.ToSql()
	if err != nil {
		return nil, err
	}
	var stats PostStats
	if err := sqlscan.Get(ctx, s.db, &stats, sqlStr, args...); err != nil {
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
	// TODO: Demonstrate how to build queries step by step with Squirrel

	qb := baseQuery

	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		qb = qb.Where(squirrel.Or{
			squirrel.ILike{"title": searchTerm},
			squirrel.ILike{"content": searchTerm},
		})
	}

	if filters.UserID != nil {
		qb = qb.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		qb = qb.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.MinWordCount != nil {
		// word count as count of " " + 1
		expr := " (LENGTH(content) - LENGTH(REPLACE(content,' ', '')) + 1) >= ? "
		qb = qb.Where(expr, *filters.MinWordCount)
	}

	if filters.OrderBy != "" {
		dir := "ASC"
		if strings.ToUpper(filters.OrderDir) == "DESC" {
			dir = "DESC"
		}

		qb = qb.OrderBy(filters.OrderBy + " " + dir)
	}

	qb = qb.Limit(uint64(filters.Limit)).Offset(uint64(filters.Offset))

	return baseQuery
}

// TODO: Implement GetTopUsers method using Squirrel with complex aggregation
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	qb := s.psql.
		Select(
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

	sqlStr, args, err := qb.ToSql()
	if err != nil {
		return nil, err
	}

	var res []UserWithStats
	if err := sqlscan.Select(ctx, s.db, &res, sqlStr, args...); err != nil {
		return nil, err
	}
	return res, nil
}

// UserWithStats represents a user with post statistics
type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}
