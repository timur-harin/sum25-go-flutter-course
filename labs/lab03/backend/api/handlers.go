package api

import (
	"encoding/json"
	"fmt"
	"io"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

// Handler contains the API handlers
type Handler struct {
	storage *storage.MemoryStorage
}

// NewHandler creates a new API handler
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage: storage}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()

	// Apply CORS middleware
	router.Use(corsMiddleware)

	// API routes
	api := router.PathPrefix("/api").Subrouter()

	// Message routes with OPTIONS support
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages", h.handleOptions).Methods("OPTIONS")

	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/messages/{id}", h.handleOptions).Methods("OPTIONS")

	// HTTP Status route with OPTIONS support
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/status/{code}", h.handleOptions).Methods("OPTIONS")

	// HTTP Cat image proxy to avoid CORS issues
	api.HandleFunc("/cat/{code}", h.GetHTTPCatImage).Methods("GET")
	api.HandleFunc("/cat/{code}", h.handleOptions).Methods("OPTIONS")

	// Health check with OPTIONS support
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	api.HandleFunc("/health", h.handleOptions).Methods("OPTIONS")

	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()

	response := models.APIResponse{
		Success: true,
		Data:    messages,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var request models.CreateMessageRequest

	if err := h.parseJSON(r, &request); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}

	if err := request.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	message, err := h.storage.Create(request.Username, request.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message")
		return
	}

	response := models.APIResponse{
		Success: true,
		Data:    message,
	}

	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	var request models.UpdateMessageRequest
	if err := h.parseJSON(r, &request); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}

	if err := request.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	message, err := h.storage.Update(id, request.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, "Message not found")
		return
	}

	response := models.APIResponse{
		Success: true,
		Data:    message,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	if err := h.storage.Delete(id); err != nil {
		h.writeError(w, http.StatusNotFound, "Message not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	statusResponse := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("http://localhost:8080/api/cat/%d", code), // Use our proxy
		Description: getHTTPStatusDescription(code),
	}

	response := models.APIResponse{
		Success: true,
		Data:    statusResponse,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// GetHTTPCatImage handles GET /api/cat/{code} - proxies HTTP Cat images
func (h *Handler) GetHTTPCatImage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	// Fetch the image from HTTP Cat API
	resp, err := http.Get(fmt.Sprintf("https://http.cat/%d", code))
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to fetch HTTP cat image")
		return
	}
	defer resp.Body.Close()

	// Copy headers
	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Cache-Control", "public, max-age=86400") // Cache for 24 hours

	// Copy the image data
	w.WriteHeader(resp.StatusCode)
	_, err = io.Copy(w, resp.Body)
	if err != nil {
		// Log error but don't write to response as headers are already sent
		log.Printf("Error copying HTTP cat image: %v", err)
	}
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	health := map[string]interface{}{
		"status":    "healthy",
		"timestamp": "2024-01-01T00:00:00Z",
		"version":   "1.0.0",
	}

	h.writeJSON(w, http.StatusOK, health)
}

// handleOptions handles OPTIONS requests for CORS preflight
func (h *Handler) handleOptions(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	response := models.APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	decoder := json.NewDecoder(r.Body)
	return decoder.Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	descriptions := map[int]string{
		100: "Continue",
		200: "OK",
		201: "Created",
		204: "No Content",
		400: "Bad Request",
		401: "Unauthorized",
		403: "Forbidden",
		404: "Not Found",
		418: "I'm a teapot",
		500: "Internal Server Error",
		503: "Service Unavailable",
	}

	if desc, exists := descriptions[code]; exists {
		return desc
	}
	return "Unknown Status"
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Allow specific origins for development
		origin := r.Header.Get("Origin")
		if origin == "http://localhost:3000" || origin == "http://127.0.0.1:3000" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
		w.Header().Set("Access-Control-Max-Age", "86400") // 24 hours

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
