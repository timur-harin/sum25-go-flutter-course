package repository

import (
	"context"
	"database/sql"
	"strings"

	"lab04-backend/models"

	"github.com/Masterminds/squirrel"
)

// SearchService handles dynamic search operations using Squirrel query builder
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

// PostStats represents aggregated post statistics
type PostStats struct {
	TotalPosts       int
	PublishedPosts   int
	ActiveUsers      int
	AvgContentLength float64
}

// UserWithStats represents a user with post statistics
type UserWithStats struct {
	models.User
	PostCount      int
	PublishedCount int
	LastPostDate   string
}

// NewSearchService creates a new SearchService
func NewSearchService(db *sql.DB) *SearchService {
	return &SearchService{
		db:   db,
		psql: squirrel.StatementBuilder.PlaceholderFormat(squirrel.Question),
	}
}

// SearchPosts using Squirrel builder
func (s *SearchService) SearchPosts(ctx context.Context, filters SearchFilters) ([]models.Post, error) {
	query := s.psql.Select("id", "user_id", "title", "content", "published", "created_at", "updated_at").
		From("posts")

	// Where conditions
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

	// Order
	orderBy := "created_at"
	if filters.OrderBy != "" {
		switch filters.OrderBy {
		case "title", "created_at", "updated_at":
			orderBy = filters.OrderBy
		}
	}
	orderDir := "DESC"
	if strings.ToUpper(filters.OrderDir) == "ASC" {
		orderDir = "ASC"
	}
	query = query.OrderBy(orderBy + " " + orderDir)

	// Limit & Offset
	if filters.Limit <= 0 {
		filters.Limit = 50
	}
	query = query.Limit(uint64(filters.Limit)).Offset(uint64(filters.Offset))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	rows, err := s.db.QueryContext(ctx, sqlStr, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		var p models.Post
		if err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, nil
}

// SearchUsers using Squirrel
func (s *SearchService) SearchUsers(ctx context.Context, nameQuery string, limit int) ([]models.User, error) {
	query := s.psql.Select("id", "name", "email", "created_at", "updated_at").
		From("users").
		Where(squirrel.Like{"name": "%" + nameQuery + "%"}).
		OrderBy("name").
		Limit(uint64(limit))

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	rows, err := s.db.QueryContext(ctx, sqlStr, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var u models.User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

// GetPostStats using aggregation and JOINs
func (s *SearchService) GetPostStats(ctx context.Context) (*PostStats, error) {
	query := s.psql.Select(
		"COUNT(p.id) AS total_posts",
		"COUNT(CASE WHEN p.published = true THEN 1 END) AS published_posts",
		"COUNT(DISTINCT p.user_id) AS active_users",
		"AVG(LENGTH(p.content)) AS avg_content_length",
	).From("posts p").
		Join("users u ON p.user_id = u.id")

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	var stats PostStats
	err = s.db.QueryRowContext(ctx, sqlStr, args...).Scan(
		&stats.TotalPosts,
		&stats.PublishedPosts,
		&stats.ActiveUsers,
		&stats.AvgContentLength,
	)
	if err != nil {
		return nil, err
	}
	return &stats, nil
}

// BuildDynamicQuery helper
func (s *SearchService) BuildDynamicQuery(base squirrel.SelectBuilder, filters SearchFilters) squirrel.SelectBuilder {
	if filters.Query != "" {
		searchTerm := "%" + filters.Query + "%"
		base = base.Where(squirrel.Or{
			squirrel.Like{"title": searchTerm},
			squirrel.Like{"content": searchTerm},
		})
	}
	if filters.UserID != nil {
		base = base.Where(squirrel.Eq{"user_id": *filters.UserID})
	}
	if filters.Published != nil {
		base = base.Where(squirrel.Eq{"published": *filters.Published})
	}
	return base
}

// GetTopUsers using Squirrel with aggregation
func (s *SearchService) GetTopUsers(ctx context.Context, limit int) ([]UserWithStats, error) {
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

	sqlStr, args, err := query.ToSql()
	if err != nil {
		return nil, err
	}

	rows, err := s.db.QueryContext(ctx, sqlStr, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []UserWithStats
	for rows.Next() {
		var u UserWithStats
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.PostCount, &u.PublishedCount, &u.LastPostDate); err != nil {
			return nil, err
		}
		results = append(results, u)
	}
	return results, nil
}
