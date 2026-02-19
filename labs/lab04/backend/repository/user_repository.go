package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"lab04-backend/models"
)

var (
	emailRegex      = regexp.MustCompile(`^[a-zA-Z0-9._%%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	ErrInvalidName  = errors.New("name must be at least 2 characters")
	ErrInvalidEmail = errors.New("email must be a valid format")
	ErrNoRows       = sql.ErrNoRows
)

type User struct {
	ID        int        `json:"id" db:"id"`
	Name      string     `json:"name" db:"name"`
	Email     string     `json:"email" db:"email"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func validateFields(name, email string) error {
	if len(name) < 2 {
		return ErrInvalidName
	}
	if !emailRegex.MatchString(email) {
		return ErrInvalidEmail
	}
	return nil
}

func (r *UserRepository) Create(req *models.CreateUserRequest) (*User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	if err := validateFields(req.Name, req.Email); err != nil {
		return nil, err
	}

	now := time.Now().UTC()
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, ?, ?)
		RETURNING id, name, email, created_at, updated_at, deleted_at
	`

	row := r.db.QueryRow(query, req.Name, req.Email, now, now)
	user := &User{}
	err := row.Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("Create: %w", err)
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at, deleted_at
		FROM users
		WHERE id = ? AND deleted_at IS NULL
	`
	user := &User{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("GetByID: %w", err)
	}
	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*User, error) {
	if !emailRegex.MatchString(email) {
		return nil, ErrInvalidEmail
	}
	query := `
		SELECT id, name, email, created_at, updated_at, deleted_at
		FROM users
		WHERE email = ? AND deleted_at IS NULL
	`
	user := &User{}
	err := r.db.QueryRow(query, email).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("GetByEmail: %w", err)
	}
	return user, nil
}

func (r *UserRepository) GetAll() ([]User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at, deleted_at
		FROM users
		WHERE deleted_at IS NULL
		ORDER BY created_at
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("GetAll: %w", err)
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(
			&u.ID, &u.Name, &u.Email,
			&u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
		); err != nil {
			return nil, fmt.Errorf("scan GetAll: %w", err)
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("GetAll rows: %w", err)
	}
	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*User, error) {
	var sets []string
	var args []interface{}

	if req.Name != nil {
		if len(*req.Name) < 2 {
			return nil, ErrInvalidName
		}
		sets = append(sets, "name = ?")
		args = append(args, *req.Name)
	}

	if req.Email != nil {
		if !emailRegex.MatchString(*req.Email) {
			return nil, ErrInvalidEmail
		}
		sets = append(sets, "email = ?")
		args = append(args, *req.Email)
	}

	if len(sets) == 0 {
		return r.GetByID(id)
	}

	sets = append(sets, "updated_at = ?")
	now := time.Now().UTC()
	args = append(args, now)
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = ? AND deleted_at IS NULL
		RETURNING id, name, email, created_at, updated_at, deleted_at
	`, strings.Join(sets, ", "))

	row := r.db.QueryRow(query, args...)
	user := &User{}
	err := row.Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("Update: %w", err)
	}
	return user, nil
}

func (r *UserRepository) Delete(id int) error {
	now := time.Now().UTC()
	res, err := r.db.Exec(`
		UPDATE users
		SET deleted_at = ?, updated_at = ?
		WHERE id = ? AND deleted_at IS NULL
	`, now, now, id)
	if err != nil {
		return fmt.Errorf("Delete: %w", err)
	}
	count, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("Delete RowsAffected: %w", err)
	}
	if count == 0 {
		return ErrNoRows
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	var cnt int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users WHERE deleted_at IS NULL").Scan(&cnt)
	if err != nil {
		return 0, fmt.Errorf("Count: %w", err)
	}
	return cnt, nil
}
