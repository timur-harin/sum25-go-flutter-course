package repository

import (
	"lab04-backend/models"

	"gorm.io/gorm"
)

// CategoryRepository handles database operations for categories using GORM
// This repository demonstrates GORM ORM approach for database operations
type CategoryRepository struct {
	db *gorm.DB
}

// NewCategoryRepository creates a new CategoryRepository with GORM
func NewCategoryRepository(gormDB *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: gormDB}
}

// Create creates a new category using GORM
func (r *CategoryRepository) Create(category *models.Category) error {
	result := r.db.Create(category)
	return result.Error
}

// GetByID retrieves a category by its ID using GORM
func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	result := r.db.First(&category, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

// GetAll retrieves all categories ordered by name using GORM
func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Order("name").Find(&categories)
	return categories, result.Error
}

// Update updates an existing category using GORM
func (r *CategoryRepository) Update(category *models.Category) error {
	result := r.db.Save(category)
	return result.Error
}

// Delete deletes a category by its ID using GORM (soft delete if configured)
func (r *CategoryRepository) Delete(id uint) error {
	result := r.db.Delete(&models.Category{}, id)
	return result.Error
}

// FindByName retrieves a category by its name using GORM
func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	result := r.db.Where("name = ?", name).First(&category)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

// SearchCategories searches for categories by name with limit using GORM
func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Where("name LIKE ?", "%"+query+"%").
		Order("name").
		Limit(limit).
		Find(&categories)
	return categories, result.Error
}

// GetCategoriesWithPosts retrieves categories along with their associated posts using GORM Preload
func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Preload("Posts").Find(&categories)
	return categories, result.Error
}

// Count returns the total number of categories using GORM
func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	result := r.db.Model(&models.Category{}).Count(&count)
	return count, result.Error
}

// CreateWithTransaction creates multiple categories within a transaction using GORM
func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for _, category := range categories {
			if err := tx.Create(&category).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
