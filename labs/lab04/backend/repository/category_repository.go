package repository

import (
	"lab04-backend/models"
	"gorm.io/gorm"
)

type CategoryRepository struct {
	db *gorm.DB
}

func NewCategoryRepository(gormDB *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: gormDB}
}

func (r *CategoryRepository) validateColor(color string) error {
	if color == "" {
		return nil
	}
	if err := (&models.Category{Color: color}).Validate(); err != nil {
		return err
	}
	return nil
}

func (r *CategoryRepository) Create(category *models.Category) error {
	if err := r.validateColor(category.Color); err != nil {
		return err
	}
	result := r.db.Create(category)
	return result.Error
}

func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	result := r.db.First(&category, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Order("name").Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) Update(category *models.Category) error {
	if err := r.validateColor(category.Color); err != nil {
		return err
	}
	result := r.db.Save(category)
	return result.Error
}

func (r *CategoryRepository) Delete(id uint) error {
	result := r.db.Delete(&models.Category{}, id)
	return result.Error
}

func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	result := r.db.Where("name = ?", name).First(&category)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Where("name LIKE ?", "%"+query+"%").
		Order("name").
		Limit(limit).
		Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Preload("Posts").Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	result := r.db.Model(&models.Category{}).Count(&count)
	return count, result.Error
}

func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for _, category := range categories {
			if err := r.validateColor(category.Color); err != nil {
				return err
			}
			if err := tx.Create(&category).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

func (r *CategoryRepository) Restore(id uint) error {
	return r.db.Unscoped().Model(&models.Category{}).Where("id = ?", id).Update("deleted_at", nil).Error
}

func (r *CategoryRepository) GetDeleted() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Unscoped().Where("deleted_at IS NOT NULL").Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) GetActiveCategories() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Scopes(models.ActiveCategories).Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) GetCategoryWithPostCount(id uint) (int64, error) {
	var category models.Category
	if err := r.db.First(&category, id).Error; err != nil {
		return 0, err
	}
	return category.PostCount(r.db), nil
}

func (r *CategoryRepository) GetCategoriesWithActivePosts() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.
		Scopes(models.ActiveCategories).
		Preload("Posts", "active = ?", true).
		Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) HardDelete(id uint) error {
	return r.db.Unscoped().Delete(&models.Category{}, id).Error
}