package main

import (
	"errors"
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
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

	log.Println("TODO: Implement main function")
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
	log.Println("Listening on port 8080")
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatalf("Server failed to start: %v", err)
	}
}
