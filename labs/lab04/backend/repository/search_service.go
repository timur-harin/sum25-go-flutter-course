package repository

import (
	"context"
	"database/sql"
	"lab04-backend/models"
	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/sqlscan"
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

func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar),
	}
}

func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	query := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

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
		query = query.Where("array_length(regexp_split_to_array(content, '\\s+'), 1) >= ?", *filters.MinWordCount)
	}

	if filters.OrderBy != "" {
		order := filters.OrderBy
		if filters.OrderDir != "" {
			order += " " + filters.OrderDir
		}
		query = query.OrderBy(order)
	} else {
		query = query.OrderBy("created_at DESC")
	}

	if filters.Limit > 0 {
		query = query.Limit(uint64(filters.Limit))
	} else {
		query = query.Limit(50)
	}

	if filters.Offset > 0 {
		query = query.Offset(uint64(filters.Offset))
	}

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sql, args...)
	return posts, err
}

func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var users []models.User
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	return users, err
}

func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(p.id) as total_posts",
		"COUNT(CASE WHEN p.published = true THEN 1 END) as published_posts",
		"COUNT(DISTINCT p.user_id) as active_users",
		"AVG(LENGTH(p.content)) as avg_content_length",
	).From("posts p")

	sql, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var stats PostStats
	err = sqlscan.Get(ctx, s.db, &stats, sql, args...)
	return &stats, err
}

type PostStats struct {
	TotalPosts       int     `db:"total_posts"`
	PublishedPosts   int     `db:"published_posts"`
	ActiveUsers      int     `db:"active_users"`
	AvgContentLength float64 `db:"avg_content_length"`
}

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
		return nil, err
	}

	var users []UserWithStats
	err = sqlscan.Select(ctx, s.db, &users, sql, args...)
	return users, err
}

type UserWithStats struct {
	models.User
	PostCount      int    `db:"post_count"`
	PublishedCount int    `db:"published_count"`
	LastPostDate   string `db:"last_post_date"`
}