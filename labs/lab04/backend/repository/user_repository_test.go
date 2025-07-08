package repository

import (
    "database/sql"
    "errors"
    "fmt"
    "strings"

    "lab04-backend/models"
)

// UserRepository handles database operations for users
type UserRepository struct {
    db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
    return &UserRepository{db: db}
}

// Create inserts a new user and returns the created entity.
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
    if req == nil {
        return nil, errors.New("request cannot be nil")
    }
    if err := req.Validate(); err != nil {
        return nil, err
    }

    query := `INSERT INTO users (name, email, created_at, updated_at)
              VALUES (?, ?, datetime('now'), datetime('now'))
              RETURNING id, name, email, created_at, updated_at`
    var u models.User
    if err := r.db.QueryRow(query, req.Name, req.Email).Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
        return nil, err
    }
    return &u, nil
}

// GetByID retrieves a user by primary key.
func (r *UserRepository) GetByID(id int) (*models.User, error) {
    query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
    var u models.User
    if err := r.db.QueryRow(query, id).Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
        return nil, err
    }
    return &u, nil
}

// GetByEmail retrieves a user by e‑mail address.
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
    query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
    var u models.User
    if err := r.db.QueryRow(query, email).Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
        return nil, err
    }
    return &u, nil
}

// GetAll returns all users ordered by creation time.
func (r *UserRepository) GetAll() ([]models.User, error) {
    rows, err := r.db.Query(`SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`)
    if err != nil {
        return nil, err
    }
    return models.ScanUsers(rows)
}

// Update updates the provided fields of a user and returns the updated record.
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
    if req == nil {
        return nil, errors.New("request cannot be nil")
    }

    setClauses := []string{}
    args := []interface{}{}

    if req.Name != nil {
        setClauses = append(setClauses, "name = ?")
        args = append(args, *req.Name)
    }
    if req.Email != nil {
        setClauses = append(setClauses, "email = ?")
        args = append(args, *req.Email)
    }

    if len(setClauses) == 0 {
        // nothing to update – just return the current state
        return r.GetByID(id)
    }

    setClauses = append(setClauses, "updated_at = datetime('now')")
    query := fmt.Sprintf("UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at", strings.Join(setClauses, ", "))
    args = append(args, id)

    var u models.User
    if err := r.db.QueryRow(query, args...).Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
        return nil, err
    }
    return &u, nil
}

// Delete removes a user by ID.
func (r *UserRepository) Delete(id int) error {
    res, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
    if err != nil {
        return err
    }
    affected, err := res.RowsAffected()
    if err != nil {
        return err
    }
    if affected == 0 {
        return sql.ErrNoRows
    }
    return nil
}

// Count returns the total number of users in the database.
func (r *UserRepository) Count() (int, error) {
    var count int
    if err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&count); err != nil {
        return 0, err
    }
    return count, nil
}