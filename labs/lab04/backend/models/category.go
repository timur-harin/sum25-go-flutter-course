// models/category.go
package models

import (
	"errors"
	"regexp"
	"time"

	"gorm.io/gorm"
)

type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7;default:'#007bff'"`
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	Posts []*Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// Остальной код остается без изменений

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

func (Category) TableName() string {
	return "categories"
}

func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Color == "" {
		c.Color = "#007bff"
	}
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	return nil
}

func (req *CreateCategoryRequest) Validate() error {
	if req.Name == "" || len(req.Name) < 2 || len(req.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if req.Color != "" && !hexColorRegex.MatchString(req.Color) {
		return errors.New("invalid color format")
	}
	return nil
}

func (req *UpdateCategoryRequest) Validate() error {
	if req.Name != nil && (len(*req.Name) < 2 || len(*req.Name) > 100) {
		return errors.New("name must be between 2 and 100 characters")
	}
	if req.Color != nil && !hexColorRegex.MatchString(*req.Color) {
		return errors.New("invalid color format")
	}
	return nil
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
	return db.Preload("Posts")
}

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) int64 {
	return db.Model(c).Association("Posts").Count()
}

func (c *Category) Validate() error {
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if c.Color != "" && !hexColorRegex.MatchString(c.Color) {
		return errors.New("invalid color format")
	}
	return nil
}

var hexColorRegex = regexp.MustCompile(`^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`)