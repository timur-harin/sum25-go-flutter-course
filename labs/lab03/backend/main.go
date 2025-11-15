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
	ms := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	h := api.NewHandler(ms)

	// Setup routes using the handler
	router := h.SetupRoutes()

	// Configure the HTTP server
	srv := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("Starting server on %s", srv.Addr)

	// Start the server and handle any errors
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server failed: %v", err)
	}
}
