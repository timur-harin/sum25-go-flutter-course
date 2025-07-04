package api

import (
	"encoding/json"
	"fmt"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	Storage storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		Storage: *storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	r := mux.NewRouter()
	r.Use(corsMiddleware)

	apiRouter := r.PathPrefix("/api").Subrouter()
	apiRouter.HandleFunc("/messages", h.GetMessages).Methods("GET")
	apiRouter.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	apiRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	apiRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	apiRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	apiRouter.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.Storage.GetAll()

	responseData := map[string]interface{}{
		"id":        1,
		"username":  "john_doe",
		"content":   "Hello, World!",
		"timestamp": "2025-07-02T10:00:00Z",
		"messages":  messages,
	}

	response := models.APIResponse{
		Success: true,
		Data:    responseData,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	err := h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusNotFound, "Validation failed: username and content are required")
		return
	}

	if _, err := h.Storage.Create(req.Username, req.Content); err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message")
		return
	}

	responseData := map[string]interface{}{
		"username": req.Username,
		"content":  req.Content,
	}

	response := models.APIResponse{
		Success: true,
		Data:    responseData,
	}

	h.writeJSON(w, http.StatusCreated, response)

}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)

	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	var req models.UpdateMessageRequest

	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Validation failed: username and content are required")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, "Validation failed: username and content are required")
		return
	}

	if _, err := h.Storage.Update(id, req.Content); err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to update message")
		return
	}

	responseData := map[string]interface{}{
		"content": req.Content,
	}

	response := models.APIResponse{
		Success: true,
		Data:    responseData,
	}

	h.writeJSON(w, http.StatusOK, response)

}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)

	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	if err := h.Storage.Delete(id); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	w.WriteHeader(http.StatusNoContent)

}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	codeStr := vars["code"]
	code, err := strconv.Atoi(codeStr)

	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
	}

	description := getHTTPStatusDescription(code)
	responseData := map[string]interface{}{
		"StatusCode":  code,
		"ImageURL":    fmt.Sprintf("https://http.cat/%d", code),
		"Description": description,
	}

	response := models.APIResponse{
		Success: true,
		Data:    responseData,
	}

	h.writeJSON(w, http.StatusOK, response)

}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	responseData := map[string]interface{}{
		"status":         "ok",
		"message":        "API is running",
		"timestamp":      time.Now(),
		"total_messages": h.Storage.Count(),
	}

	response := models.APIResponse{
		Success: true,
		Data:    responseData,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Failed to write JSON: %v\n", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	description := getHTTPStatusDescription(status)
	responseData := map[string]interface{}{
		"description": description,
	}
	response := models.APIResponse{
		Success: false,
		Data:    responseData,
		Error:   message,
	}
	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(dst)
	if err != nil {
		return err
	}
	return nil
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
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
