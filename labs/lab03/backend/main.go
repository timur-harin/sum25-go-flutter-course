package main

import (
	"context"
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	memStorage := storage.NewMemoryStorage()
	
	handler := api.NewHandler(memStorage)
	
	router := handler.SetupRoutes()
	
	server := &http.Server{
		Addr:         ":8081",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	
	log.Printf("Starting server on %s", server.Addr)
	log.Println("Available endpoints:")
	log.Println("  GET    /api/messages")
	log.Println("  POST   /api/messages")
	log.Println("  PUT    /api/messages/{id}")
	log.Println("  DELETE /api/messages/{id}")
	log.Println("  GET    /api/status/{code}")
	log.Println("  GET    /api/health")
	
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()
	
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")
	
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}
	
	log.Println("Server exited")
}
