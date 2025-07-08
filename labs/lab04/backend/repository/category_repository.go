package repository

import (
	"fmt"

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

// TODO: Implement Create method using GORM
func (r *CategoryRepository) Create(category *models.Category) error {
	// TODO: Create a new category using GORM
	// - Use GORM's Create method: r.db.Create(category)
	// - GORM automatically handles ID generation and timestamps
	// - No need for manual SQL or RETURNING clauses
	// Example: result := r.db.Create(category)
	// return result.Error
	//
	// Notice how much simpler this is compared to manual SQL!
	return fmt.Errorf("TODO: implement Create method with GORM")
}

// TODO: Implement GetByID method using GORM
func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	// TODO: Get category by ID using GORM
	// - Use GORM's First method: r.db.First(&category, id)
	// - GORM automatically generates the WHERE clause
	// - Returns gorm.ErrRecordNotFound if not found
	// Example:
	// var category models.Category
	// result := r.db.First(&category, id)
	// return &category, result.Error
	//
	// Much cleaner than manual row scanning!
	return nil, fmt.Errorf("TODO: implement GetByID method with GORM")
}

// TODO: Implement GetAll method using GORM
func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	// TODO: Get all categories using GORM
	// - Use GORM's Find method: r.db.Find(&categories)
	// - GORM automatically handles the slice allocation
	// - Can add Order() for sorting: r.db.Order("name").Find(&categories)
	// Example:
	// var categories []models.Category
	// result := r.db.Order("name").Find(&categories)
	// return categories, result.Error
	return nil, fmt.Errorf("TODO: implement GetAll method with GORM")
}

// TODO: Implement Update method using GORM
func (r *CategoryRepository) Update(category *models.Category) error {
	// TODO: Update category using GORM
	// - Use GORM's Save method: r.db.Save(category)
	// - GORM automatically updates only changed fields
	// - Handles updated_at timestamp automatically
	// - Alternative: r.db.Model(category).Updates(updates)
	//
	// Example:
	// result := r.db.Save(category)
	// return result.Error
	return fmt.Errorf("TODO: implement Update method with GORM")
}

// TODO: Implement Delete method using GORM
func (r *CategoryRepository) Delete(id uint) error {
	// TODO: Delete category using GORM
	// - Use GORM's Delete method: r.db.Delete(&models.Category{}, id)
	// - GORM can do soft delete if model has DeletedAt field
	// - For hard delete: r.db.Unscoped().Delete(&models.Category{}, id)
	//
	// Example:
	// result := r.db.Delete(&models.Category{}, id)
	// return result.Error
	return fmt.Errorf("TODO: implement Delete method with GORM")
}

// TODO: Implement FindByName method using GORM
func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	// TODO: Find category by name using GORM
	// - Use GORM's Where method: r.db.Where("name = ?", name).First(&category)
	// - GORM handles SQL injection protection automatically
	// - Can use struct for conditions: r.db.Where(&models.Category{Name: name}).First(&category)
	//
	// Example:
	// var category models.Category
	// result := r.db.Where("name = ?", name).First(&category)
	// return &category, result.Error
	return nil, fmt.Errorf("TODO: implement FindByName method with GORM")
}

// TODO: Implement SearchCategories method using GORM
func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	// TODO: Search categories using GORM
	// - Use GORM's Where with LIKE: r.db.Where("name LIKE ?", "%"+query+"%")
	// - Add Limit: .Limit(limit)
	// - Add Order: .Order("name")
	//
	// Example:
	// var categories []models.Category
	// result := r.db.Where("name LIKE ?", "%"+query+"%").
	//               Order("name").
	//               Limit(limit).
	//               Find(&categories)
	// return categories, result.Error
	return nil, fmt.Errorf("TODO: implement SearchCategories method with GORM")
}

// TODO: Implement GetCategoriesWithPosts method using GORM associations
func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	// TODO: Get categories with associated posts using GORM
	// - Use GORM's Preload to load associations: r.db.Preload("Posts").Find(&categories)
	// - GORM automatically handles the JOINs and relationships
	// - Much simpler than manual JOIN queries!
	//
	// Example:
	// var categories []models.Category
	// result := r.db.Preload("Posts").Find(&categories)
	// return categories, result.Error
	//
	// This assumes Category model has Posts relationship defined
	return nil, fmt.Errorf("TODO: implement GetCategoriesWithPosts method with GORM Preload")
}

// TODO: Implement Count method using GORM
func (r *CategoryRepository) Count() (int64, error) {
	// TODO: Count categories using GORM
	// - Use GORM's Count method: r.db.Model(&models.Category{}).Count(&count)
	// - GORM returns int64 for count operations
	//
	// Example:
	// var count int64
	// result := r.db.Model(&models.Category{}).Count(&count)
	// return count, result.Error
	return 0, fmt.Errorf("TODO: implement Count method with GORM")
}

// TODO: Implement Transaction example using GORM
func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	// TODO: Create multiple categories in a transaction using GORM
	// - Use GORM's Transaction method: r.db.Transaction(func(tx *gorm.DB) error {...})
	// - GORM automatically handles rollback on error
	// - Much simpler than manual transaction management!
	//
	// Example:
	// return r.db.Transaction(func(tx *gorm.DB) error {
	//     for _, category := range categories {
	//         if err := tx.Create(&category).Error; err != nil {
	//             return err // GORM will rollback automatically
	//         }
	//     }
	//     return nil // GORM will commit automatically
	// })
	return fmt.Errorf("TODO: implement CreateWithTransaction method with GORM")
}
