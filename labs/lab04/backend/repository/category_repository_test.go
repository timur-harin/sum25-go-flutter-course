package repository

import (
	"testing"
	"time"

	"lab04-backend/models"

	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB(t *testing.T) *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	err = db.AutoMigrate(&models.Category{}, &models.Post{})
	assert.NoError(t, err)
	return db
}

func TestCategoryRepository_CRUD(t *testing.T) {
	db := setupTestDB(t)
	repo := NewCategoryRepository(db)

	category := &models.Category{
		Name:        "Tech",
		Description: "Tech desc",
		Color:       "#123abc",
	}

	t.Run("Create", func(t *testing.T) {
		err := repo.Create(category)
		assert.NoError(t, err)
		assert.NotZero(t, category.ID)
		assert.WithinDuration(t, time.Now(), category.CreatedAt, time.Second)
	})

	t.Run("GetByID", func(t *testing.T) {
		fetched, err := repo.GetByID(category.ID)
		assert.NoError(t, err)
		assert.Equal(t, category.Name, fetched.Name)
	})

	t.Run("Update", func(t *testing.T) {
		category.Name = "Updated Tech"
		err := repo.Update(category)
		assert.NoError(t, err)
		updated, _ := repo.GetByID(category.ID)
		assert.Equal(t, "Updated Tech", updated.Name)
	})

	t.Run("FindByName", func(t *testing.T) {
		found, err := repo.FindByName("Updated Tech")
		assert.NoError(t, err)
		assert.Equal(t, category.ID, found.ID)
	})

	t.Run("GetAll", func(t *testing.T) {
		all, err := repo.GetAll()
		assert.NoError(t, err)
		assert.Len(t, all, 1)
	})

	t.Run("Count", func(t *testing.T) {
		count, err := repo.Count()
		assert.NoError(t, err)
		assert.Equal(t, int64(1), count)
	})

	t.Run("SearchCategories", func(t *testing.T) {
		results, err := repo.SearchCategories("Tech", 10)
		assert.NoError(t, err)
		assert.GreaterOrEqual(t, len(results), 1)
	})

	t.Run("GetCategoriesWithPosts", func(t *testing.T) {
		// No posts yet
		withPosts, err := repo.GetCategoriesWithPosts()
		assert.NoError(t, err)
		assert.Len(t, withPosts, 1)
		assert.Empty(t, withPosts[0].Posts)
	})

	t.Run("Delete", func(t *testing.T) {
		err := repo.Delete(category.ID)
		assert.NoError(t, err)
		_, err = repo.GetByID(category.ID)
		assert.Error(t, err)
		assert.Equal(t, gorm.ErrRecordNotFound, err)
	})
}

func TestCategoryRepository_CreateWithTransaction(t *testing.T) {
	db := setupTestDB(t)
	repo := NewCategoryRepository(db)

	categories := []models.Category{
		{Name: "Cat1"},
		{Name: "Cat2"},
	}

	err := repo.CreateWithTransaction(categories)
	assert.NoError(t, err)

	all, err := repo.GetAll()
	assert.NoError(t, err)
	assert.Len(t, all, 2)
}
