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
	store := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(store)

	// Setup routes using the handler
	router := handler.SetupRoutes()

	// Configure server
	srv := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Logging server start
	log.Println("Starting server on :8080")

	// Start the server and handle any errors
	if err := srv.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
