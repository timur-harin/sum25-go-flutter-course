package api

import (
	"encoding/json"
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
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		storage: storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()
	
	// Add CORS middleware
	router.Use(corsMiddleware)
	
	// Create API v1 subrouter with prefix "/api"
	apiRouter := router.PathPrefix("/api").Subrouter()
	
	// Add routes
	apiRouter.HandleFunc("/messages", h.GetMessages).Methods("GET")
	apiRouter.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	apiRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	apiRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	apiRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	apiRouter.HandleFunc("/health", h.HealthCheck).Methods("GET")
	
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
	var req models.CreateMessageRequest
	
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON: "+err.Error())
		return
	}
	
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	
	message, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message: "+err.Error())
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
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}
	
	var req models.UpdateMessageRequest
	
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON: "+err.Error())
		return
	}
	
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	
	message, err := h.storage.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
			return
		}
		h.writeError(w, http.StatusInternalServerError, "Failed to update message: "+err.Error())
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
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}
	
	err = h.storage.Delete(id)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
			return
		}
		h.writeError(w, http.StatusInternalServerError, "Failed to delete message: "+err.Error())
		return
	}
	
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}
	
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}
	
	statusResponse := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "https://http.cat/" + strconv.Itoa(code),
		Description: getHTTPStatusDescription(code),
	}
	
	response := models.APIResponse{
		Success: true,
		Data:    statusResponse,
	}
	
	h.writeJSON(w, http.StatusOK, response)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	healthData := map[string]interface{}{
		"status":         "ok",
		"message":        "API is running",
		"timestamp":      time.Now(),
		"total_messages": h.storage.Count(),
	}
	
	h.writeJSON(w, http.StatusOK, healthData)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error encoding JSON: %v", err)
	}
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
	case 403:
		return "Forbidden"
	case 404:
		return "Not Found"
	case 418:
		return "I'm a teapot"
	case 500:
		return "Internal Server Error"
	case 503:
		return "Service Unavailable"
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
		
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		
		next.ServeHTTP(w, r)
	})
}