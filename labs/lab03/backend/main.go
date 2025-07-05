package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	// Create a new memory storage instance
	storage := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(storage)

	// Setup routes using the handler
	router := handler.SetupRoutes()

	// Configure server with:
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Add logging to show server is starting
	log.Println("Server starting on :8080")

	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}
