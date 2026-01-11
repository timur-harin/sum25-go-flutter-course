package repository

import (
	"context"
	"database/sql"
	"fmt"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/sqlscan"
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
	query := s.psql.
		Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	// WHERE
	if filters.Query != "" {
		search := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.ILike{"title": search},
			squirrel.ILike{"content": search},
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

	// ORDER BY
	orderField := filters.OrderBy
	if orderField == "" {
		orderField = "created_at"
	}
	orderDir := filters.OrderDir
	if orderDir != "DESC" {
		orderDir = "ASC"
	}
	query = query.OrderBy(fmt.Sprintf("%s %s", orderField, orderDir))

	// LIMIT & OFFSET
	if filters.Limit <= 0 {
		filters.Limit = 50
	}
	query = query.Limit(uint64(filters.Limit)).Offset(uint64(filters.Offset))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var posts []models.Post
	if err := sqlscan.Select(ctx, s.db, &posts, sqlStr, args...); err != nil {
		return nil, err
	}

	return posts, nil
}

// TODO: Implement SearchUsers method using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.
		Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.ILike{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sqlStr, args, err := query.ToSql()
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
	query := s.psql.
		Select(
			"COUNT(p.id) AS total_posts",
			"COUNT(CASE WHEN p.published = true THEN 1 END) AS published_posts",
			"COUNT(DISTINCT p.user_id) AS active_users",
			"AVG(LENGTH(p.content)) AS avg_content_length",
		).
		From("posts p").
		Join("users u ON u.id = p.user_id")

	sqlStr, args, err := query.ToSql()
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
	query := baseQuery

	if filters.Query != "" {
		search := "%" + filters.Query + "%"
		query = query.Where(squirrel.Or{
			squirrel.ILike{"title": search},
			squirrel.ILike{"content": search},
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
	return query
}

// TODO: Implement GetTopUsers method using Squirrel with complex aggregation
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	query := s.psql.
		Select(
			"u.id", "u.name", "u.email", "u.created_at", "u.updated_at",
			"COUNT(p.id) AS post_count",
			"COUNT(CASE WHEN p.published = true THEN 1 END) AS published_count",
			"MAX(p.created_at) AS last_post_date",
		).
		From("users u").
		LeftJoin("posts p ON p.user_id = u.id").
		GroupBy("u.id", "u.name", "u.email", "u.created_at", "u.updated_at").
		OrderBy("post_count DESC").
		Limit(uint64(limit))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var result []UserWithStats
	if err := sqlscan.Select(ctx, s.db, &result, sqlStr, args...); err != nil {
		return nil, err
	}

	return result, nil
}

// UserWithStats represents a user with post statistics
type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}
