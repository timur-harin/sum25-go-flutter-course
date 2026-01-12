package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/v2/sqlscan"
)

type SearchService struct {
	db   *sql.DB
	psql squirrel.StatementBuilderType
}

type SearchFilters struct {
	Query     string
	UserID    *int
	Published *bool
	Limit     int
	Offset    int
	OrderBy   string
	OrderDir  string
}

type PostStats struct {
	TotalPosts       int     `db:"total_posts"`
	PublishedPosts   int     `db:"published_posts"`
	ActiveUsers      int     `db:"active_users"`
	AvgContentLength float64 `db:"avg_content_length"`
}

type UserWithStats struct {
	ID             int            `db:"id"`
	Name           string         `db:"name"`
	Email          string         `db:"email"`
	CreatedAt      time.Time      `db:"created_at"`
	UpdatedAt      time.Time      `db:"updated_at"`
	PostCount      int            `db:"post_count"`
	PublishedCount int            `db:"published_count"`
	LastPostDate   sql.NullString `db:"last_post_date"`
}

func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar),
	}
}

func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	baseQuery := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	query := s.buildDynamicPostQuery(baseQuery, filters)

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build sql query: %w", err)
	}

	var posts []models.Post
	if err := sqlscan.Select(ctx, s.db, &posts, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute search query: %w", err)
	}

	return posts, nil
}

func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	searchTerm := "%" + strings.ToLower(nameQuery) + "%"

	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Expr("LOWER(name) LIKE ?", searchTerm)).
		OrderBy("name").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build user search query: %w", err)
	}

	var users []models.User
	if err := sqlscan.Select(ctx, s.db, &users, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to execute user search query: %w", err)
	}

	return users, nil
}

func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COALESCE(COUNT(p.id), 0) as total_posts",
		"COALESCE(SUM(CASE WHEN p.published THEN 1 ELSE 0 END), 0) as published_posts",
		"COALESCE(COUNT(DISTINCT p.user_id), 0) as active_users",
		"COALESCE(AVG(LENGTH(p.content)), 0.0) as avg_content_length",
	).From("posts p")

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build post stats query: %w", err)
	}

	var stats PostStats
	if err := sqlscan.Get(ctx, s.db, &stats, sql, args...); err != nil {
		if sqlscan.NotFound(err) {
			return &PostStats{}, nil
		}
		return nil, fmt.Errorf("failed to get post stats: %w", err)
	}

	return &stats, nil
}

func (s *SearchService) buildDynamicPostQuery(baseQuery squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	query := baseQuery

	if filters.Query != "" {
		searchTerm := "%" + strings.ToLower(filters.Query) + "%"
		query = query.Where(squirrel.Or{
			squirrel.Expr("LOWER(title) LIKE ?", searchTerm),
			squirrel.Expr("LOWER(content) LIKE ?", searchTerm),
		})
	}

	if filters.UserID != nil {
		query = query.Where(squirrel.Eq{"user_id": *filters.UserID})
	}

	if filters.Published != nil {
		query = query.Where(squirrel.Eq{"published": *filters.Published})
	}

	if filters.Limit > 0 {
		query = query.Limit(uint64(filters.Limit))
	} else {
		query = query.Limit(50)
	}

	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	orderBy := "created_at"
	validOrderBy := map[string]bool{"title": true, "created_at": true, "updated_at": true}
	if filters.OrderBy != "" && validOrderBy[strings.ToLower(filters.OrderBy)] {
		orderBy = filters.OrderBy
	}

	orderDir := "DESC"
	if strings.ToUpper(filters.OrderDir) == "ASC" {
		orderDir = "ASC"
	}

	query = query.OrderBy(fmt.Sprintf("%s %s", orderBy, orderDir))

	return query
}

func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	query := s.psql.Select(
		"u.id", "u.name", "u.email", "u.created_at", "u.updated_at",
		"COALESCE(COUNT(p.id), 0) as post_count",
		"COALESCE(SUM(CASE WHEN p.published THEN 1 ELSE 0 END), 0) as published_count",
		"MAX(p.created_at) as last_post_date",
	).From("users u").
		LeftJoin("posts p ON u.id = p.user_id").
		GroupBy("u.id", "u.name", "u.email", "u.created_at", "u.updated_at").
		OrderBy("post_count DESC", "u.name ASC").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, fmt.Errorf("failed to build top users query: %w", err)
	}

	var users []UserWithStats
	if err := sqlscan.Select(ctx, s.db, &users, sql, args...); err != nil {
		return nil, fmt.Errorf("failed to get top users: %w", err)
	}

	return users, nil
}
