package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"

	"github.com/rs/cors"
)

func main() {
	storage := storage.NewMemoryStorage()
	handler := api.NewHandler(storage)
	router := handler.SetupRoutes()

	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"}, // или конкретный адрес фронта
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: true,
	})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      c.Handler(router), // ← обернуть роутер в CORS-мидлвар
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Server started on :8080")
	log.Fatal(srv.ListenAndServe())
}
