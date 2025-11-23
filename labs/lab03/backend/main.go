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
	// TODO: Create a new memory storage instance
	store := storage.NewMemoryStorage()

	// TODO: Create a new API handler with the storage
	h := api.NewHandler(store)

	// TODO: Setup routes using the handler
	router := h.SetupRoutes()

	// TODO: Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	c := cors.New(cors.Options{
		AllowedOrigins:     []string{"http://localhost:3000"},
		AllowedMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:     []string{"Content-Type", "Authorization"},
		AllowCredentials:   true,
		OptionsPassthrough: false,
	})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      c.Handler(router),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// TODO: Add logging to show server is starting
	// TODO: Start the server and handle any errors
	log.Println("Server started on :8080")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Could not start server: %v\n", err)
	}
}
