package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	storage := storage.NewMemoryStorage()
	handler := api.NewHandler(storage)
	router := handler.SetupRoutes()

	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Server is running on http://localhost:8080")

	// Запускаем сервер
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
