package repository

import (
	"errors"
	"fmt"

	"lab04-backend/models"

	"gorm.io/gorm"
)

type CategoryRepository struct {
	db *gorm.DB
}

func NewCategoryRepository(db *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: db}
}

// Create creates a new category
func (r *CategoryRepository) Create(category *models.Category) error {
	result := r.db.Create(category)
	if result.Error != nil {
		return fmt.Errorf("failed to create category: %w", result.Error)
	}
	return nil
}

// GetByID gets a category by ID
func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	result := r.db.First(&category, id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("category not found")
		}
		return nil, fmt.Errorf("failed to get category: %w", result.Error)
	}
	return &category, nil
}

// GetAll gets all categories
func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Order("name").Find(&categories)
	if result.Error != nil {
		return nil, fmt.Errorf("failed to get categories: %w", result.Error)
	}
	return categories, nil
}

// Update updates a category
func (r *CategoryRepository) Update(category *models.Category) error {
	result := r.db.Save(category)
	if result.Error != nil {
		return fmt.Errorf("failed to update category: %w", result.Error)
	}
	return nil
}

// Delete deletes a category
func (r *CategoryRepository) Delete(id uint) error {
	result := r.db.Delete(&models.Category{}, id)
	if result.Error != nil {
		return fmt.Errorf("failed to delete category: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("category not found")
	}
	return nil
}

// FindByName finds a category by name
func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	result := r.db.Where("name = ?", name).First(&category)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("category not found")
		}
		return nil, fmt.Errorf("failed to find category: %w", result.Error)
	}
	return &category, nil
}

// SearchCategories searches categories by name
func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Where("name LIKE ?", "%"+query+"%").
		Order("name").
		Limit(limit).
		Find(&categories)
	if result.Error != nil {
		return nil, fmt.Errorf("failed to search categories: %w", result.Error)
	}
	return categories, nil
}

// GetCategoriesWithPosts gets categories with their posts
func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Preload("Posts").Find(&categories)
	if result.Error != nil {
		return nil, fmt.Errorf("failed to get categories with posts: %w", result.Error)
	}
	return categories, nil
}

// Count counts all categories
func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	result := r.db.Model(&models.Category{}).Count(&count)
	if result.Error != nil {
		return 0, fmt.Errorf("failed to count categories: %w", result.Error)
	}
	return count, nil
}

// CreateWithTransaction creates multiple categories in a transaction
func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for _, category := range categories {
			if err := tx.Create(&category).Error; err != nil {
				return fmt.Errorf("failed to create category: %w", err)
			}
		}
		return nil
	})
}
