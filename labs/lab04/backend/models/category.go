package models

import (
	"errors"
	"log"
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

// TableName specifies the table name for GORM (optional - GORM auto-infers)
func (Category) TableName() string {
	return "categories"
}

func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if len(c.Name) == 0 || len(c.Name) > 100 {
		return errors.New("name between 1 and 100 characters")
	}

	if len(c.Description) > 500 {
		return errors.New("description no longer than 500 characters")
	}

	c.Active = true

	if c.Color == "" {
		c.Color = "#007bff"
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: ID=%d, Name=%s", c.ID, c.Name)
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if len(c.Name) == 0 || len(c.Name) > 100 {
		return errors.New("name between 1 and 100 characters")
	}

	if len(c.Description) > 500 {
		return errors.New("description no longer than 500 characters")
	}
	return nil
}

// TODO: Implement Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	if len(req.Name) < 1 || len(req.Name) > 100 {
		return errors.New("name between 1 and 100 characters")
	}
	if len(req.Description) > 500 {
		return errors.New("description no longer than 500 characters")
	}
	return nil
}

func (req *CreateCategoryRequest) ToCategory() *Category {
	if err := req.Validate(); err != nil {
		log.Printf("invalid category request: %v", err)
		return nil
	}

	c := &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}

	if c.Color == "" {
		c.Color = "#007bff"
	}

	return c
}

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	return db.Model(c).Association("Posts").Count(), nil
}
