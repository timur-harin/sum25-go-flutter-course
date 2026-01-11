package repository

import (
	"database/sql"
	"strings"
	"time"

	"lab04-backend/models"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if validationErr := req.Validate(); validationErr != nil {
		return nil, validationErr
	}
	currentTime := time.Now()
	query := "INSERT INTO users (name, email, created_at, updated_at) VALUES ($1, $2, $3, $4) RETURNING id, name, email, created_at, updated_at"
	user := &models.User{}
	err := r.db.QueryRow(query, req.Name, req.Email, currentTime, currentTime).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	user := &models.User{}
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1"
	err := r.db.QueryRow(query, id).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	user := &models.User{}
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1"
	err := r.db.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at"
	rows, queryErr := r.db.Query(query)
	if queryErr != nil {
		return nil, queryErr
	}
	defer rows.Close()
	var userList []models.User
	for rows.Next() {
		user := models.User{}
		if scanErr := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); scanErr != nil {
			return nil, scanErr
		}
		userList = append(userList, user)
	}
	return userList, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	var setClauses []string
	var params []interface{}
	if req.Name != nil {
		setClauses = append(setClauses, "name = $1")
		params = append(params, *req.Name)
	}
	if req.Email != nil {
		setClauses = append(setClauses, "email = $2")
		params = append(params, *req.Email)
	}
	setClauses = append(setClauses, "updated_at = $3")
	currentTime := time.Now()
	params = append(params, currentTime)
	params = append(params, id)
	query := "UPDATE users SET " + strings.Join(setClauses, ", ") + " WHERE id = $4 RETURNING id, name, email, created_at, updated_at"
	user := &models.User{}
	err := r.db.QueryRow(query, params...).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) Delete(id int) error {
	query := "DELETE FROM users WHERE id = $1"
	result, execErr := r.db.Exec(query, id)
	if execErr != nil {
		return execErr
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	var total int
	query := "SELECT COUNT(*) FROM users"
	err := r.db.QueryRow(query).Scan(&total)
	if err != nil {
		return 0, err
	}
	return total, nil
}