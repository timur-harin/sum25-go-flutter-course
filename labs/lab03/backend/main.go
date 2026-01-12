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
		AllowedOrigins:       []string{"http://localhost:3000"}, // 👈 именно это значение ждёт тест
		AllowedMethods:       []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:       []string{"Content-Type"},
		ExposedHeaders:       []string{"Content-Type", "Access-Control-Allow-Origin", "Access-Control-Allow-Methods"},
		AllowCredentials:     true,
		OptionsPassthrough:   false,
		OptionsSuccessStatus: 200,
	})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      c.Handler(router),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Server started on :8080")
	log.Fatal(srv.ListenAndServe())
}
