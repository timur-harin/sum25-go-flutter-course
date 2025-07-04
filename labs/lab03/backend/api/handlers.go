package api

import (
	"encoding/json"
	"fmt"
	"lab03-backend/models"
	"lab03-backend/storage"
	"net/http"
	"strconv"
	"time"
	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage: storage}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()
	router.Use(corsMiddleware)
	// API v1 subrouter with prefix "/api"
	api := router.PathPrefix("/api").Subrouter()
	// GET /messages -> h.GetMessages
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	// POST /messages -> h.CreateMessage
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	// PUT /messages/{id} -> h.UpdateMessage
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	// DELETE /messages/{id} -> h.DeleteMessage
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	// GET /status/{code} -> h.GetHTTPStatus
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	// GET /health -> h.HealthCheck
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()

	response := models.APIResponse{
		Success: true,
		Data: messages,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var requestBody models.CreateMessageRequest

	if err := h.parseJSON(r, &requestBody); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid json")
	}

	if err := requestBody.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	
	message, err := h.storage.Create(requestBody.Username, requestBody.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "cant create message")
	}

	response := models.APIResponse{
		Success: true,
		Data: message,
	}

	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	var requestBody models.UpdateMessageRequest
	vars := mux.Vars(r)

	id, err := strconv.Atoi(vars["id"])
	if err != nil || id > len(h.storage.GetAll()) || id < 1 {
		h.writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.parseJSON(r, &requestBody); err != nil  {
		h.writeError(w, http.StatusBadRequest, "invalid json")
	}

	if err := requestBody.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	message, err := h.storage.Update(id, requestBody.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "cant update message")
	}

	response := models.APIResponse{
		Success: true,
		Data: message,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil || id > len(h.storage.GetAll()) || id < 1 {
		h.writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.storage.Delete(id); err != nil {
		h.writeError(w, http.StatusInternalServerError, "message not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code > 599 || code < 100 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
	}

	statusResponse := models.HTTPStatusResponse{
		StatusCode: code,
		ImageURL: fmt.Sprintf("https://http.cat/%d", code),
		Description: getHTTPStatusDescription(code),
	}

	response := models.APIResponse{
		Success: true,
		Data: statusResponse,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	healthStatus := map[string]interface{}{
		"status":	"ok",
		"message":	"API is running",
		"timestamp":	time.Now(),
		"total_messages":	h.storage.Count(),
	}

	h.writeJSON(w, http.StatusOK, healthStatus)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "failed to encode", http.StatusInternalServerError)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	response := models.APIResponse{
		Success: false,
		Error: message,
	}

	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	switch code {
		case 200:
			return "OK"
		case 201:
			return "Created"
		case 204:
			return "No Content"
		case 400:
			return "Bad Request"
		case 401:
			return "Unauthorized"
		case 404:
			return "Not Found"
		case 500:
			return "Internal Server Error"
		default:
			return "Unknown Status"
	}
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
