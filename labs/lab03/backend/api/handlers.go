package api

import (
	"encoding/json"
	"github.com/gorilla/mux"
	"io"
	"lab03-backend/models"
	"lab03-backend/storage"
	"net/http"
	"strconv"
	"time"
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

	api := router.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	api.HandleFunc("/cat/{code}", h.ServeHTTPImage).Methods("GET")

	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    messages,
	})
}

// ServeHTTPImage handles GET /api/cat/{code}
func (h *Handler) ServeHTTPImage(w http.ResponseWriter, r *http.Request) {
	code := mux.Vars(r)["code"]

	resp, err := http.Get("https://http.cat/" + code)
	if err != nil {
		http.Error(w, "Failed to fetch image", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		http.Error(w, "Image not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	w.WriteHeader(http.StatusOK)
	_, _ = io.Copy(w, resp.Body)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Could not create message")
		return
	}

	h.writeJSON(w, http.StatusCreated, models.APIResponse{
		Success: true,
		Data:    msg,
	})
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	idStr := mux.Vars(r)["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.storage.Update(id, req.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, "Message not found")
		return
	}

	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    msg,
	})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	idStr := mux.Vars(r)["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
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
	codeStr := mux.Vars(r)["code"]
	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid HTTP status code")
		return
	}

	resp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "http://localhost:8080/api/cat/" + codeStr,
		Description: getHTTPStatusDescription(code),
	}

	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    resp,
	})
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	resp := map[string]interface{}{
		"status":         "healthy",
		"message":        "API is running",
		"timestamp":      time.Now().Format(time.RFC3339),
		"total_messages": len(h.storage.GetAll()),
	}
	h.writeJSON(w, http.StatusOK, resp)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Error encoding JSON", http.StatusInternalServerError)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	resp := models.APIResponse{Success: false, Error: message}
	h.writeJSON(w, status, resp)
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
		origin := r.Header.Get("Origin")
		if origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		}
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
