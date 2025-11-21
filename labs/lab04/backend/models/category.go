package models

import (
	"errors"
	"log"
	"regexp"
	"strings"
	"time"

	"gorm.io/gorm"
)

// Category represents a blog post category using GORM model conventions
// This model demonstrates GORM ORM patterns and relationships
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"` // Hex color code
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"` // Soft delete support

	// GORM Associations (demonstrates ORM relationships)
	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// CreateCategoryRequest represents the payload for creating a category
type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

// UpdateCategoryRequest represents the payload for updating a category
type UpdateCategoryRequest struct {
	Name        *string `json:"name,omitempty" validate:"omitempty,min=2,max=100"`
	Description *string `json:"description,omitempty" validate:"omitempty,max=500"`
	Color       *string `json:"color,omitempty" validate:"omitempty,hexcolor"`
	Active      *bool   `json:"active,omitempty"`
}

// TODO: Implement GORM model methods and hooks

// TableName specifies the table name for GORM (optional - GORM auto-infers)
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook: set default values and perform pre-creation logic
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Color == "" {
		c.Color = "#007bff"
	}
	c.Active = true
	c.Name = stringTrim(c.Name)
	c.Description = stringTrim(c.Description)

	// Проверка уникальности имени (если есть подключение к БД)
	if tx != nil && tx.Statement != nil && tx.Statement.DB != nil {
		var count int64
		err := tx.Model(&Category{}).Where("name = ?", c.Name).Count(&count).Error
		if err == nil && count > 0 {
			return errors.New("category name must be unique")
		}
	}
	return nil
}

func stringTrim(s string) string {
	for len(s) > 0 && (s[0] == ' ' || s[0] == '\t' || s[0] == '\n' || s[0] == '\r') {
		s = s[1:]
	}
	for len(s) > 0 && (s[len(s)-1] == ' ' || s[len(s)-1] == '\t' || s[len(s)-1] == '\n' || s[len(s)-1] == '\r') {
		s = s[:len(s)-1]
	}
	return s
}

// AfterCreate hook: логирование, уведомления, обновление кэша
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// Log creation
	log.Printf("Category created: %s (ID: %d)", c.Name, c.ID)

	// Send notifications (stub)
	go func(categoryName string) {
		log.Printf("Notification: New category created: %s", categoryName)
	}(c.Name)

	// Update cache (stub)
	go func(categoryID uint, categoryName string) {
		log.Printf("Cache updated for category: %d (%s)", categoryID, categoryName)
	}(c.ID, c.Name)

	return nil
}

// BeforeUpdate hook: валидация, запрет изменения ID, обработка деактивации
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	c.Name = stringTrim(c.Name)
	c.Description = stringTrim(c.Description)
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return gorm.ErrInvalidData
	}
	if len(c.Description) > 500 {
		return gorm.ErrInvalidData
	}
	// Запрет изменения ID
	if tx.Statement.Changed("ID") {
		return errors.New("cannot change category ID")
	}
	// Если деактивируем категорию — деактивируем посты (stub)
	if tx.Statement.Changed("Active") && !c.Active {
		go func(categoryID uint) {
			log.Printf("Related posts for category %d marked as inactive (stub)", categoryID)
		}(c.ID)
	}
	return nil
}

// Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	// Trim spaces
	req.Name = strings.TrimSpace(req.Name)
	req.Description = strings.TrimSpace(req.Description)
	req.Color = strings.TrimSpace(req.Color)
	// Name: required, length 2-100
	if len(req.Name) < 2 || len(req.Name) > 100 {
		return errors.New("category name must be between 2 and 100 characters")
	}
	// Description: max 500
	if len(req.Description) > 500 {
		return errors.New("category description must not exceed 500 characters")
	}
	// Color: if present, must be valid hex color (#RRGGBB)
	if req.Color != "" {
		matched, _ := regexp.MatchString(`^#[0-9a-fA-F]{6}$`, req.Color)
		if !matched {
			return errors.New("color must be a valid hex code in the format #RRGGBB")
		}
	}
	return nil
}

// ToCategory: преобразует CreateCategoryRequest в Category
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

// GORM scope for active categories
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// GORM scope for categories with posts (через ассоциацию)
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories ON post_categories.category_id = categories.id").Joins("JOIN posts ON posts.id = post_categories.post_id")
}

// Проверяет, активна ли категория
func (c *Category) IsActive() bool {
	return c.Active
}

// Подсчёт постов через ассоциацию GORM
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	var count int64
	err := db.Model(&Post{}).Where("id IN (SELECT post_id FROM post_categories WHERE category_id = ?)", c.ID).Count(&count).Error
	return count, err
}
