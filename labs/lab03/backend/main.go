package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	DB := storage.NewMemoryStorage()
	app := api.NewHandler(DB)
	router := app.SetupRoutes()
	
	
	srv := &http.Server{
		Addr: ":8080",
		Handler: router,
		ReadTimeout: 15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout: 60 * time.Second,
	}
	
	log.Println("Server listenning on :8080")
	
	if err := srv.ListenAndServe(); err != nil {
		log.Println(err)
	}
}
