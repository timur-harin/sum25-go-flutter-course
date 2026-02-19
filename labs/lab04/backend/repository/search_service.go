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

type SearchService struct {
	db   *sql.DB
	psql squirrel.StatementBuilderType
}

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

type PostStats struct {
	TotalPosts       int     `db:"total_posts"`
	PublishedPosts   int     `db:"published_posts"`
	ActiveUsers      int     `db:"active_users"`
	AvgContentLength float64 `db:"avg_content_length"`
}

type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}

func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar),
	}
}

// SearchPosts searches for posts based on filters
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	query := s.psql.Select(
		"id",
		"user_id",
		"title",
		"content",
		"published",
		"created_at",
		"updated_at",
	).From("posts")

	// Apply filters
	if filters.Query != "" {
		searchTerm := "%" + strings.ToLower(filters.Query) + "%"
		query = query.Where(squirrel.Or{
			squirrel.Like{"LOWER(title)": searchTerm},
			squirrel.Like{"LOWER(content)": searchTerm},
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	// Apply ordering
	if filters.OrderBy != "" {
		orderBy := filters.OrderBy
		switch orderBy {
		case "title", "created_at", "updated_at":
			orderDir := "ASC"
			if strings.ToUpper(filters.OrderDir) == "DESC" {
				orderDir = "DESC"
			}
			query = query.OrderBy(fmt.Sprintf("%s %s", orderBy, orderDir))
		}
	} else {
		query = query.OrderBy("created_at DESC")
	}

	// Apply limit/offset
	if filters.Limit <= 0 {
		filters.Limit = 50
	}
	query = query.Limit(uint64(filters.Limit))

	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	// Build and execute query
	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to search posts: %w", err)
	}

	return posts, nil
}

// SearchUsers searches for users by name
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	if limit <= 0 {
		limit = 50
	}

	query := s.psql.Select(
		"id",
		"name",
		"email",
		"created_at",
		"updated_at",
	).From("users").
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	var users []models.User
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to search users: %w", err)
	}

	return users, nil
}

// GetPostStats gets post statistics
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(id) as total_posts",
		"COUNT(CASE WHEN published = true THEN 1 END) as published_posts",
		"COUNT(DISTINCT user_id) as active_users",
		"AVG(LENGTH(content)) as avg_content_length",
	).From("posts")

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build query: %w", err)
	}

	var stats PostStats
	err = sqlscan.Get(ctx, s.db, &stats, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get post stats: %w", err)
	}

	return &stats, nil
}

// BuildDynamicQuery builds a dynamic query based on filters
func (s *SearchService) BuildDynamicQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	query := baseQuery

	if filters.Query != "" {
		searchTerm := "%" + strings.ToLower(filters.Query) + "%"
		query = query.Where(squirrel.Or{
			squirrel.Like{"LOWER(title)": searchTerm},
			squirrel.Like{"LOWER(content)": searchTerm},
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.OrderBy != "" {
		orderBy := filters.OrderBy
		switch orderBy {
		case "title", "created_at", "updated_at":
			orderDir := "ASC"
			if strings.ToUpper(filters.OrderDir) == "DESC" {
				orderDir = "DESC"
			}
			query = query.OrderBy(fmt.Sprintf("%s %s", orderBy, orderDir))
		}
	}

	if filters.Limit > 0 {
		query = query.Limit(uint64(filters.Limit))
	}

	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	return query
}

// GetTopUsers gets top users by post count
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	if limit <= 0 {
		limit = 10
	}

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

	var users []UserWithStats
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get top users: %w", err)
	}

	return users, nil
}
