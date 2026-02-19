package models

import (
	"errors"
	"regexp"
	"time"

	"gorm.io/gorm"
)

// Category represents a blog post category
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"` // Hex color code
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"` // Soft delete support
	Posts       []Post         `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// CreateCategoryRequest represents the payload for creating a category
type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

// BeforeCreate hook validates data before creation
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Name == "" {
		return errors.New("category name cannot be empty")
	}
	if len(c.Name) > 100 {
		return errors.New("category name too long")
	}
	if len(c.Description) > 500 {
		return errors.New("category description too long")
	}
	if c.Color != "" {
		if matched, _ := regexp.MatchString(`^#[0-9a-fA-F]{6}$`, c.Color); !matched {
			return errors.New("invalid color format")
		}
	} else {
		c.Color = "#007bff" // Default color
	}
	return nil
}

// AfterCreate hook logs after creation
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// In a real application, you might log this or send notifications
	return nil
}

// BeforeUpdate hook validates data before update
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if c.Name == "" {
		return errors.New("category name cannot be empty")
	}
	if len(c.Name) > 100 {
		return errors.New("category name too long")
	}
	if len(c.Description) > 500 {
		return errors.New("category description too long")
	}
	if c.Color != "" {
		if matched, _ := regexp.MatchString(`^#[0-9a-fA-F]{6}$`, c.Color); !matched {
			return errors.New("invalid color format")
		}
	}
	return nil
}

// Validate validates the CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	if req.Name == "" {
		return errors.New("name cannot be empty")
	}
	if len(req.Name) < 2 || len(req.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if len(req.Description) > 500 {
		return errors.New("description too long")
	}
	if req.Color != "" {
		if matched, _ := regexp.MatchString(`^#[0-9a-fA-F]{6}$`, req.Color); !matched {
			return errors.New("invalid color format")
		}
	}
	return nil
}

// ToCategory converts CreateCategoryRequest to Category
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

// ActiveCategories scope filters active categories
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts scope filters categories with posts
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories ON post_categories.category_id = categories.id").
		Group("categories.id")
}

// IsActive checks if category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount gets post count for this category
func (c *Category) PostCount(db *gorm.DB) int64 {
	return db.Model(c).Association("Posts").Count()
}
