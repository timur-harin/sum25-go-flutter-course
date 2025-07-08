package repository

import (
	"database/sql"
	"fmt"

	"lab04-backend/models"
)

// PostRepository handles database operations for posts
// This repository demonstrates SCANY MAPPING approach for result scanning
type PostRepository struct {
	db *sql.DB
}

// NewPostRepository creates a new PostRepository
func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

// TODO: Implement Create method using scany for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	// TODO: Create a new post in the database using scany for result mapping
	// - Validate the request using req.Validate()
	// - Insert into posts table with RETURNING clause
	// - Use sqlscan.Get() to scan the RETURNING result into a Post struct
	// Example: sqlscan.Get(context.Background(), r.db, &post, query, args...)
	// This eliminates manual row scanning compared to user repository
	return nil, fmt.Errorf("TODO: implement Create method with scany mapping")
}

// TODO: Implement GetByID method using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	// TODO: Get post by ID from database using scany
	// - Use sqlscan.Get() instead of manual row.Scan()
	// Example: sqlscan.Get(context.Background(), r.db, &post, "SELECT * FROM posts WHERE id = $1", id)
	// Notice how this eliminates the need for manual field scanning
	return nil, fmt.Errorf("TODO: implement GetByID method with scany")
}

// TODO: Implement GetByUserID method using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	// TODO: Get all posts by user ID using scany
	// - Use sqlscan.Select() for multiple rows instead of manual rows.Next() loop
	// Example: sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	// This eliminates manual iteration and scanning
	return nil, fmt.Errorf("TODO: implement GetByUserID method with scany")
}

// TODO: Implement GetPublished method using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	// TODO: Get all published posts using scany
	// - Use sqlscan.Select() for multiple rows
	// - Query posts where published = true
	// - Order by created_at DESC
	return nil, fmt.Errorf("TODO: implement GetPublished method with scany")
}

// TODO: Implement GetAll method using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	// TODO: Get all posts from database using scany
	// - Use sqlscan.Select() instead of manual rows iteration
	// Example: sqlscan.Select(context.Background(), r.db, &posts, "SELECT * FROM posts ORDER BY created_at DESC")
	// Compare this simplicity with manual scanning in user repository
	return nil, fmt.Errorf("TODO: implement GetAll method with scany")
}

// TODO: Implement Update method using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	// TODO: Update post in database using scany
	// - Build dynamic UPDATE query based on non-nil fields in req
	// - Update updated_at timestamp
	// - Use sqlscan.Get() with RETURNING clause to get updated post
	// This avoids a separate SELECT query after UPDATE
	return nil, fmt.Errorf("TODO: implement Update method with scany")
}

// TODO: Implement Delete method (standard SQL)
func (r *PostRepository) Delete(id int) error {
	// TODO: Delete post from database
	// - Delete from posts table by ID
	// - Return error if post doesn't exist
	// Note: Delete operations typically don't need scany since no data is returned
	return fmt.Errorf("TODO: implement Delete method")
}

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	// TODO: Count total number of posts
	// - Return count of posts in database
	// - Can use standard QueryRow.Scan() for single values like count
	return 0, fmt.Errorf("TODO: implement Count method")
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	// TODO: Count posts by user ID
	// - Return count of posts for specific user
	// - Use standard QueryRow.Scan() for single integer result
	return 0, fmt.Errorf("TODO: implement CountByUserID method")
}
