package models

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
)

// Category represents a blog post category using GORM model conventions
// This model demonstrates GORM ORM patterns and relationships
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"`
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

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
	if strings.TrimSpace(c.Color) == "" {
		c.Color = "#007bff"
	}
	if strings.TrimSpace(c.Name) == "" || len(c.Name) < 2 {
		return fmt.Errorf("invalid name: must be at least 2 characters")
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: %s (ID: %d)", c.Name, c.ID)
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if len(c.Description) > 500 {
		return fmt.Errorf("description is too long")
	}
	return nil
}

func (req *CreateCategoryRequest) Validate() error {
	validate := validator.New()
	_ = validate.RegisterValidation("hexcolor", func(fl validator.FieldLevel) bool {
		color := fl.Field().String()
		return strings.HasPrefix(color, "#") && (len(color) == 7)
	})
	return validate.Struct(req)
}

func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories pc ON pc.category_id = categories.id").
		Joins("JOIN posts p ON p.id = pc.post_id").
		Where("p.id IS NOT NULL").Group("categories.id")
}

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	return db.Model(c).Association("Posts").Count(), nil
}
