package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	memoryStorage := storage.NewMemoryStorage()
	handler := api.NewHandler(memoryStorage)
	router := handler.SetupRoutes()

	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Server starting on :8080")
	if err := server.ListenAndServe(); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}
