package main

import (
	"log"
	"net/http"
	"time"
)

type MemoryStorage struct {
}

func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{}
}

type APIHandler struct {
	storage *MemoryStorage
}

func NewAPIHandler(storage *MemoryStorage) *APIHandler {
	return &APIHandler{storage: storage}
}

func (h *APIHandler) SumHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Sum endpoint is working"))
}

func main() {
	storage := NewMemoryStorage()

	handler := NewAPIHandler(storage)

	router := http.NewServeMux()
	router.HandleFunc("/api/sum", handler.SumHandler)

	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	log.Println("Server is starting on :8080")

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Could not start server: %v", err)
	}
}
