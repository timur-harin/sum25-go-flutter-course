package main

import (
	"fmt"
	"log"

	"lab04-backend/database"
	"lab04-backend/models"
	"lab04-backend/repository"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close()

	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)

	fmt.Println("Database initialized successfully!")
	fmt.Printf("User repository: %T\n", userRepo)
	fmt.Printf("Post repository: %T\n", postRepo)

	// Пример создания пользователя
	newUserReq := &models.CreateUserRequest{
		Name:  "Alice",
		Email: "alice@example.com",
	}
	user, err := userRepo.Create(newUserReq)
	if err != nil {
		log.Fatalf("Create user failed: %v", err)
	}
	fmt.Printf("Created user: %+v\n", user)

	// Пример создания поста (предполагаем, что модель CreatePostRequest есть)
	newPostReq := &models.CreatePostRequest{
		UserID:    user.ID,
		Title:     "Hello World",
		Content:   "This is my first post",
		Published: true,
	}
	post, err := postRepo.Create(newPostReq)
	if err != nil {
		log.Fatalf("Create post failed: %v", err)
	}
	fmt.Printf("Created post: %+v\n", post)

	// Получаем всех пользователей
	users, err := userRepo.GetAll()
	if err != nil {
		log.Fatalf("GetAll users failed: %v", err)
	}
	fmt.Printf("All users (%d): %+v\n", len(users), users)

	// Получаем все опубликованные посты
	posts, err := postRepo.GetPublished()
	if err != nil {
		log.Fatalf("GetPublished posts failed: %v", err)
	}
	fmt.Printf("Published posts (%d): %+v\n", len(posts), posts)

	// Обновляем пользователя
	updateUserReq := &models.UpdateUserRequest{
		Name:  ptrString("Alice Updated"),
		Email: nil,
	}
	updatedUser, err := userRepo.Update(user.ID, updateUserReq)
	if err != nil {
		log.Fatalf("Update user failed: %v", err)
	}
	fmt.Printf("Updated user: %+v\n", updatedUser)

	// Удаляем пост
	err = postRepo.Delete(post.ID)
	if err != nil {
		log.Fatalf("Delete post failed: %v", err)
	}
	fmt.Println("Deleted post successfully")

	// Подсчет пользователей
	count, err := userRepo.Count()
	if err != nil {
		log.Fatalf("Count users failed: %v", err)
	}
	fmt.Printf("Total users count: %d\n", count)
}

func ptrString(s string) *string {
	return &s
}
