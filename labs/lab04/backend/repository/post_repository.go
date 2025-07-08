package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"lab04-backend/models"

	"github.com/georgysavva/scany/v2/sqlscan"
)

// PostRepository демонстрирует подход Scany Mapping.
type PostRepository struct {
	db *sql.DB
}

// NewPostRepository создаёт новый PostRepository.
func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

// -----------------------------------------------------------------------------
// Create
// -----------------------------------------------------------------------------

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if req == nil {
		return nil, errors.New("request is nil")
	}
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, user_id, title, content, published, created_at, updated_at;
	`

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query,
		req.UserID, req.Title, req.Content, req.Published)
	return &post, err
}

// -----------------------------------------------------------------------------
// Read
// -----------------------------------------------------------------------------

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post,
		`SELECT id, user_id, title, content, published, created_at, updated_at
		 FROM posts WHERE id = ?`, id)
	return &post, err
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		`SELECT id, user_id, title, content, published, created_at, updated_at
		 FROM posts
		 WHERE user_id = ?
		 ORDER BY created_at DESC`, userID)
	return posts, err
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		`SELECT id, user_id, title, content, published, created_at, updated_at
		 FROM posts
		 WHERE published = 1
		 ORDER BY created_at DESC`)
	return posts, err
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		`SELECT id, user_id, title, content, published, created_at, updated_at
		 FROM posts
		 ORDER BY created_at DESC`)
	return posts, err
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	if req == nil {
		return nil, errors.New("request is nil")
	}

	var (
		setClauses []string
		args       []any
	)

	if req.Title != nil {
		setClauses = append(setClauses, "title = ?")
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		setClauses = append(setClauses, "content = ?")
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		setClauses = append(setClauses, "published = ?")
		args = append(args, *req.Published)
	}
	if len(setClauses) == 0 {
		return nil, errors.New("no fields to update")
	}

	// updated_at всегда обновляем
	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")

	args = append(args, id)

	query := fmt.Sprintf(`UPDATE posts SET %s WHERE id = ? 
		RETURNING id, user_id, title, content, published, created_at, updated_at`,
		strings.Join(setClauses, ", "))

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	return &post, err
}

// -----------------------------------------------------------------------------
// Delete
// -----------------------------------------------------------------------------

func (r *PostRepository) Delete(id int) error {
	res, err := r.db.Exec(`DELETE FROM posts WHERE id = ?`, id)
	if err != nil {
		return err
	}
	aff, err := res.RowsAffected()
	if err == nil && aff == 0 {
		return sql.ErrNoRows
	}
	return err
}

// -----------------------------------------------------------------------------
// Aggregates
// -----------------------------------------------------------------------------

func (r *PostRepository) Count() (int, error) {
	var cnt int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM posts`).Scan(&cnt)
	return cnt, err
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var cnt int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM posts WHERE user_id = ?`, userID).Scan(&cnt)
	return cnt, err
}
