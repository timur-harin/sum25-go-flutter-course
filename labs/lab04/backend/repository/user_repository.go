package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users
// This repository demonstrates MANUAL SQL approach with database/sql package
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
        return nil, err
    }

    var u models.User
    query := `
        INSERT INTO users (name, email)
        VALUES (?, ?)
        RETURNING id, name, email, created_at, updated_at
    `
    if err := r.db.QueryRow(query, req.Name, req.Email).Scan(
        &u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
    ); err != nil {
        return nil, err
    }
    return &u, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	var u models.User
    query := `
        SELECT id, name, email, created_at, updated_at
        FROM users WHERE id = ?
    `
    err := r.db.QueryRow(query, id).Scan(
        &u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
    )
    if err != nil {
        return nil, err
    }
    return &u, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var u models.User
    query := `
        SELECT id, name, email, created_at, updated_at
        FROM users WHERE email = ?
    `
    err := r.db.QueryRow(query, email).Scan(
        &u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
    )
    if err != nil {
        return nil, err
    }
    return &u, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`
        SELECT id, name, email, created_at, updated_at
        FROM users ORDER BY created_at
    `)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    users := []models.User{}
    for rows.Next() {
        var u models.User
        if err := rows.Scan(
            &u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
        ); err != nil {
            return nil, err
        }
        users = append(users, u)
    }
    return users, nil
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	sets := []string{}
    args := []interface{}{}
    if req.Name != nil {
        sets = append(sets, "name = ?")
        args = append(args, *req.Name)
    }
    if req.Email != nil {
        sets = append(sets, "email = ?")
        args = append(args, *req.Email)
    }
    if len(sets) == 0 {
        return r.GetByID(id)
    }
    // sets = append(sets, "updated_at = CURRENT_TIMESTAMP")
	updatedAt := time.Now()
	sets = append(sets, "updated_at = ?")
	args = append(args, updatedAt)

    query := fmt.Sprintf(
        "UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at",
        strings.Join(sets, ", "),
    )
    args = append(args, id)

    var u models.User
    err := r.db.QueryRow(query, args...).Scan(
        &u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
    )
    if err != nil {
        return nil, err
    }
    return &u, nil
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
    if err != nil {
        return err
    }
    n, err := res.RowsAffected()
    if err != nil {
        return err
    }
    if n == 0 {
        return sql.ErrNoRows
    }
    return nil
}

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	var count int
    err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&count)
    if err != nil {
        return 0, err
    }
    return count, nil
}
