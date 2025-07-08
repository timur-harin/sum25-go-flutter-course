package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
	"github.com/georgysavva/scany/v2/sqlscan"
)

// -----------------------------------------------------------------------------
// SearchService — динамические запросы с Squirrel
// -----------------------------------------------------------------------------

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

type SearchService struct {
	db   *sql.DB
	psql squirrel.StatementBuilderType
}

func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Question), // SQLite — знак ?
	}
}

// -----------------------------------------------------------------------------
// SearchPosts
// -----------------------------------------------------------------------------

func (s *SearchService) SearchPosts(ctx context.Context, f SearchFilters) ([]models.Post, error) {
	// Базовый запрос
	query := s.psql.
		Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	// Применяем динамические условия через вспомогательную функцию
	query = s.BuildDynamicQuery(query, f)

	// ORDER BY
	orderField := map[string]bool{
		"title":      true,
		"created_at": true,
		"updated_at": true,
	}[strings.ToLower(f.OrderBy)]
	if !orderField {
		f.OrderBy = "created_at"
	}
	orderDir := strings.ToUpper(f.OrderDir)
	if orderDir != "ASC" {
		orderDir = "DESC"
	}
	query = query.OrderBy(fmt.Sprintf("%s %s", f.OrderBy, orderDir))

	// LIMIT / OFFSET
	if f.Limit <= 0 || f.Limit > 1000 {
		f.Limit = 50
	}
	query = query.Limit(uint64(f.Limit)).Offset(uint64(f.Offset))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var posts []models.Post
	err = sqlscan.Select(ctx, s.db, &posts, sqlStr, args...)
	return posts, err
}

// -----------------------------------------------------------------------------
// SearchUsers
// -----------------------------------------------------------------------------

func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	if strings.TrimSpace(nameQuery) == "" {
		return nil, errors.New("nameQuery cannot be empty")
	}
	if limit <= 0 || limit > 1000 {
		limit = 50
	}

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

// -----------------------------------------------------------------------------
// GetPostStats — агрегаты с JOIN
// -----------------------------------------------------------------------------

func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.
		Select(
			"COUNT(p.id)                                   AS total_posts",
			"COUNT(CASE WHEN p.published = 1 THEN 1 END)   AS published_posts",
			"COUNT(DISTINCT p.user_id)                     AS active_users",
			"AVG(LENGTH(p.content))                        AS avg_content_length",
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

// -----------------------------------------------------------------------------
// BuildDynamicQuery — модульное добавление WHERE
// -----------------------------------------------------------------------------

func (s *SearchService) BuildDynamicQuery(base squirrel.SelectBuilder, f SearchFilters) squirrel.SelectBuilder {
	q := base

	if strings.TrimSpace(f.Query) != "" {
		pattern := "%" + f.Query + "%"
		q = q.Where(squirrel.Or{
			squirrel.Like{"title": pattern},
			squirrel.Like{"content": pattern},
		})
	}

	if f.UserID != nil {
		q = q.Where(squirrel.Eq{"user_id": *f.UserID})
	}

	if f.Published != nil {
		q = q.Where(squirrel.Eq{"published": *f.Published})
	}

	if f.MinWordCount != nil && *f.MinWordCount > 0 {
		// Простейшая оценка количества слов через пробелы
		// word_count = LENGTH(content) - LENGTH(REPLACE(content,' ','') ) + 1
		q = q.Where(fmt.Sprintf(`(LENGTH(content) - LENGTH(REPLACE(content,' ','')) + 1) >= %d`, *f.MinWordCount))
	}

	return q
}

// -----------------------------------------------------------------------------
// GetTopUsers — сложные агрегаты
// -----------------------------------------------------------------------------

func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
	if limit <= 0 || limit > 1000 {
		limit = 10
	}

	query := s.psql.
		Select(
			"u.id", "u.name", "u.email", "u.created_at", "u.updated_at",
			"COUNT(p.id)                                   AS post_count",
			"COUNT(CASE WHEN p.published = 1 THEN 1 END)   AS published_count",
			"MAX(p.created_at)                             AS last_post_date",
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

	var users []UserWithStats
	err = sqlscan.Select(ctx, s.db, &users, sqlStr, args...)
	return users, err
}

// -----------------------------------------------------------------------------
// Структуры для агрегатов
// -----------------------------------------------------------------------------

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
