package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	// TODO: Create a new memory storage instance
	// TODO: Create a new API handler with the storage
	// TODO: Setup routes using the handler
	// TODO: Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	// TODO: Add logging to show server is starting
	// TODO: Start the server and handle any errors

	// Create a new memory storage instance
	store := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(store)

	// Setup routes using the handler
	router := handler.SetupRoutes()

	// Configure server with timeouts
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Add logging to show server is starting
	log.Println("Server is starting on http://localhost:8080")

	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Could not start server: %v", err)
	}
}
