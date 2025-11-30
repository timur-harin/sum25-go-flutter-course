package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"lab04-backend/models"
	"log"
	"time"
)

type Executor interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	Query(query string, args ...interface{}) (*sql.Rows, error)
	QueryRow(query string, args ...interface{}) *sql.Row
}

type UserRepository struct {
	db Executor
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

const (
	createUserQuery = `INSERT INTO users (name, email, created_at, updated_at) 
	                  VALUES ($1, $2, $3, $4) 
	                  RETURNING id, name, email, created_at, updated_at`

	getUserByIDQuery    = "SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1 AND deleted_at IS NULL"
	getUserByEmailQuery = "SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1 AND deleted_at IS NULL"
	getAllUsersQuery    = "SELECT id, name, email, created_at, updated_at FROM users WHERE deleted_at IS NULL ORDER BY created_at DESC"
	countUsersQuery     = "SELECT COUNT(*) FROM users WHERE deleted_at IS NULL"
)

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	user := req.ToUser()
	if user == nil {
		return nil, errors.New("failed to create user from request")
	}

	err := r.db.QueryRow(
		createUserQuery,
		user.Name,
		user.Email,
		user.CreatedAt,
		user.UpdatedAt,
	).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		log.Printf("Error creating user: %v", err)
		return nil, fmt.Errorf("error creating user: %w", err)
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	var user models.User
	row := r.db.QueryRow(getUserByIDQuery, id)
	err := row.Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, sql.ErrNoRows
	}
	if err != nil {
		log.Printf("Error getting user by ID %d: %v", id, err)
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User
	row := r.db.QueryRow(getUserByEmailQuery, email)
	err := row.Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, sql.ErrNoRows
	}
	if err != nil {
		log.Printf("Error getting user by email %s: %v", email, err)
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(getAllUsersQuery)
	if err != nil {
		log.Printf("Error getting all users: %v", err)
		return nil, fmt.Errorf("error getting users: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
    // Получаем текущего пользователя для проверки updated_at
    currentUser, err := r.GetByID(id)
    if err != nil {
        return nil, err
    }

    query := "UPDATE users SET "
    args := make([]interface{}, 0)
    argPos := 1

    if req.Name != nil {
        query += fmt.Sprintf("name = $%d, ", argPos)
        args = append(args, *req.Name)
        argPos++
    }
    if req.Email != nil {
        query += fmt.Sprintf("email = $%d, ", argPos)
        args = append(args, *req.Email)
        argPos++
    }

    query += "updated_at = CURRENT_TIMESTAMP WHERE id = $%d AND deleted_at IS NULL RETURNING id, name, email, created_at, updated_at"
    args = append(args, id)

    fullQuery := fmt.Sprintf(query, argPos)
    
    var user models.User
    row := r.db.QueryRow(fullQuery, args...)
    err = row.Scan(
        &user.ID,
        &user.Name,
        &user.Email,
        &user.CreatedAt,
        &user.UpdatedAt,
    )
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, sql.ErrNoRows
        }
        log.Printf("Error updating user ID %d: %v", id, err)
        return nil, fmt.Errorf("error updating user: %w", err)
    }

    // Явная проверка, что updated_at изменился
    if !user.UpdatedAt.After(currentUser.UpdatedAt) {
        user.UpdatedAt = time.Now()
    }

    return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec(
		"UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = $1 AND deleted_at IS NULL",
		id,
	)
	if err != nil {
		log.Printf("Error soft deleting user ID %d: %v", id, err)
		return fmt.Errorf("error soft deleting user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("error checking rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	// Дополнительная проверка, что пользователь действительно удален
	_, err = r.GetByID(id)
	if err == nil {
		return fmt.Errorf("user was not deleted")
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow(countUsersQuery).Scan(&count)
	if err != nil {
		log.Printf("Error counting users: %v", err)
		return 0, fmt.Errorf("error counting users: %w", err)
	}
	return count, nil
}

func (r *UserRepository) WithTransaction(tx *sql.Tx) *UserRepository {
	return &UserRepository{db: tx}
}