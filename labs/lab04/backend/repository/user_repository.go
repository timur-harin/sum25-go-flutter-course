package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"
	"lab04-backend/models"
)

// UserRepository — работа с таблицей users ручным SQL.
type UserRepository struct {
	db *sql.DB
}

// Конструктор
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// -----------------------------------------------------------------------------
// Create
// -----------------------------------------------------------------------------

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, errors.New("request is nil")
	}
	if err := req.Validate(); err != nil {
		return nil, err
	}

	res, err := r.db.Exec(`
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
		strings.TrimSpace(req.Name),
		strings.TrimSpace(req.Email),
	)
	if err != nil {
		return nil, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, err
	}

	return r.GetByID(int(id))
}

// -----------------------------------------------------------------------------
// Read
// -----------------------------------------------------------------------------

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	var user models.User
	row := r.db.QueryRow(`
		SELECT id, name, email, created_at, updated_at
		FROM users WHERE id = ?`, id)

	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User
	row := r.db.QueryRow(`
		SELECT id, name, email, created_at, updated_at
		FROM users WHERE email = ?`, email)

	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`
		SELECT id, name, email, created_at, updated_at
		FROM users ORDER BY created_at`)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, errors.New("request is nil")
	}

	var (
		setParts []string
		args     []any
	)

	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if len(name) < 2 {
			return nil, errors.New("name must be at least 2 characters")
		}
		setParts = append(setParts, "name = ?")
		args = append(args, name)
	}

	if req.Email != nil {
		email := strings.TrimSpace(*req.Email)
		// Проверка email с валидным фиктивным именем
		if err := (&models.User{Name: "ValidName", Email: email}).Validate(); err != nil {
			return nil, fmt.Errorf("invalid email: %w", err)
		}
		setParts = append(setParts, "email = ?")
		args = append(args, email)
	}

	if len(setParts) == 0 {
		// ничего не обновляем — возвращаем текущего
		return r.GetByID(id)
	}

	updatedAt := time.Now().UTC()
	setParts = append(setParts, "updated_at = ?")
	args = append(args, updatedAt)
	query := fmt.Sprintf(`UPDATE users SET %s WHERE id = ?`, strings.Join(setParts, ", "))
	args = append(args, id)

	res, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}
	aff, _ := res.RowsAffected()
	if aff == 0 {
		return nil, sql.ErrNoRows
	}

	return r.GetByID(id)
}

// -----------------------------------------------------------------------------
// Delete
// -----------------------------------------------------------------------------

func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
	if err != nil {
		return err
	}
	aff, _ := res.RowsAffected()
	if aff == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// -----------------------------------------------------------------------------
// Aggregates
// -----------------------------------------------------------------------------

func (r *UserRepository) Count() (int, error) {
	var cnt int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&cnt)
	return cnt, err
}
