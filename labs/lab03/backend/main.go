package main

import (
	"log"
	"net/http"
	"time"
)

// Placeholder for storage and handler implementations
type MemoryStorage struct{}

func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{}
}

type APIHandler struct {
	storage *MemoryStorage
}

func NewAPIHandler(storage *MemoryStorage) *APIHandler {
	return &APIHandler{storage: storage}
}

func (h *APIHandler) SetupRoutes() *http.ServeMux {
	mux := http.NewServeMux()
	// Add your actual routes here
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Server is running"))
	})
	return mux
}

func main() {
	// Create a new memory storage instance
	storage := NewMemoryStorage()

	// Create a new API handler with the storage
	handler := NewAPIHandler(storage)

	// Setup routes using the handler
	router := handler.SetupRoutes()

	// Configure server
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Log server start
	log.Println("Starting server on :8080")

	// Start the server and handle errors
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
