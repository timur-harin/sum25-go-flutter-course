package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"lab04-backend/models"

	"github.com/georgysavva/scany/v2/sqlscan"
)

type PostRepository struct {
	db *sql.DB
}

func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `
		INSERT INTO posts (title, content, user_id, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING *;
	`

	post := new(models.Post)
	err := sqlscan.Get(context.Background(), r.db, post, query,
		req.Title,
		req.Content,
		req.UserID,
		req.Published,
	)

	return post, err
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `SELECT * FROM posts WHERE id = $1`

	post := new(models.Post)
	err := sqlscan.Get(context.Background(), r.db, post, query, id)

	return post, err
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC`

	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)

	return posts, err
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `
		SELECT * FROM posts
		WHERE published = TRUE
		ORDER BY created_at DESC;
	`

	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)

	return posts, err
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `SELECT * FROM posts ORDER BY created_at DESC`

	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)

	return posts, err
}

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	set := []string{}
	args := []interface{}{}
	argID := 1

	if req.Title != nil {
		set = append(set, fmt.Sprintf("title = $%d", argID))
		args = append(args, *req.Title)
		argID++
	}
	if req.Content != nil {
		set = append(set, fmt.Sprintf("content = $%d", argID))
		args = append(args, *req.Content)
		argID++
	}
	// Убираем CategoryID, его нет в модели
	if req.Published != nil {
		set = append(set, fmt.Sprintf("published = $%d", argID))
		args = append(args, *req.Published)
		argID++
	}

	set = append(set, fmt.Sprintf("updated_at = $%d", argID))
	args = append(args, time.Now())
	argID++

	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE posts
		SET %s
		WHERE id = $%d
		RETURNING *;
	`, joinSet(set), argID)

	post := new(models.Post)
	err := sqlscan.Get(context.Background(), r.db, post, query, args...)

	return post, err
}

// joinSet is a helper to join set parts with ", "
func joinSet(parts []string) string {
	return fmt.Sprintf("%s", sqlJoin(parts, ", "))
}

// sqlJoin joins SQL fragments with given separator
func sqlJoin(parts []string, sep string) string {
	if len(parts) == 0 {
		return ""
	}
	out := parts[0]
	for _, part := range parts[1:] {
		out += sep + part
	}
	return out
}

func (r *PostRepository) Delete(id int) error {
	query := `DELETE FROM posts WHERE id = $1`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

func (r *PostRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM posts`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	query := `SELECT COUNT(*) FROM posts WHERE user_id = $1`
	var count int
	err := r.db.QueryRow(query, userID).Scan(&count)
	return count, err
}
