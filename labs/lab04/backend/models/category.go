package models

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
)

type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

// Category represents a blog post category using GORM model conventions
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"` // Hex color code
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// TableName specifies the table name for GORM (optional)
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook for setting defaults and validation
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// Default color
	if strings.TrimSpace(c.Color) == "" {
		c.Color = "#007bff"
	}

	// Basic validation
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return fmt.Errorf("category name must be between 2 and 100 characters")
	}

	if len(c.Description) > 500 {
		return fmt.Errorf("description too long (max 500 characters)")
	}

	return nil
}

// AfterCreate hook to log creation
func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: ID=%d, Name=%s", c.ID, c.Name)
	return nil
}

// BeforeUpdate hook for validation
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if c.Name != "" && (len(c.Name) < 2 || len(c.Name) > 100) {
		return fmt.Errorf("updated category name must be between 2 and 100 characters")
	}

	if len(c.Description) > 500 {
		return fmt.Errorf("updated description too long (max 500 characters)")
	}

	return nil
}

// Validate performs validation on CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	validate := validator.New()
	validate.RegisterValidation("hexcolor", func(fl validator.FieldLevel) bool {
		val := fl.Field().String()
		if len(val) != 7 || !strings.HasPrefix(val, "#") {
			return false
		}
		for _, r := range val[1:] {
			if !strings.Contains("0123456789abcdefABCDEF", string(r)) {
				return false
			}
		}
		return true
	})

	return validate.Struct(req)
}

// ToCategory converts CreateCategoryRequest to Category model
func (req *CreateCategoryRequest) ToCategory() *Category {
	color := req.Color
	if color == "" {
		color = "#007bff"
	}
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       color,
		Active:      true,
	}
}

// ActiveCategories returns GORM scope for filtering active categories
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts returns GORM scope for categories with at least one post
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.
		Joins("JOIN post_categories ON categories.id = post_categories.category_id").
		Joins("JOIN posts ON posts.id = post_categories.post_id").
		Group("categories.id")
}

// IsActive returns whether the category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount returns the number of associated posts
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	var count int64
	err := db.
		Model(&Post{}).
		Joins("JOIN post_categories ON post_categories.post_id = posts.id").
		Where("post_categories.category_id = ?", c.ID).
		Count(&count).Error
	return count, err
}
