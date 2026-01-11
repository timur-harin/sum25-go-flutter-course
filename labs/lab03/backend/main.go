package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	memory := storage.NewMemoryStorage()
	handler := api.NewHandler(memory)
	mux := handler.SetupRoutes()
	server := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	log.Println("Server is running on :8080")
	log.Fatal(server.ListenAndServe())
}
