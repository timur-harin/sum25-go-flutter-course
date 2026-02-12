package api

import (
	"encoding/json"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"strings"
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
	api := router.PathPrefix("/api").Subrouter()
	router.Use(corsMiddleware)
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()
	log.Println(messages)
	response := models.APIResponse{Success: true, Data: messages, Error: ""}
	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var createMessageRequest models.CreateMessageRequest
	if err := h.parseJSON(r, &createMessageRequest); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	h.storage.Create(createMessageRequest.Username, createMessageRequest.Content)
	response := models.APIResponse{Success: true, Data: createMessageRequest, Error: "no"}
	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 3 {
		http.Error(w, "Invalid path", http.StatusBadRequest)
		return
	}
	id, _ := strconv.Atoi(parts[2])
	var updateMessageRequest models.UpdateMessageRequest
	if err := h.parseJSON(r, &updateMessageRequest); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	content := updateMessageRequest.Content
	h.storage.Update(id, content)
	response := models.APIResponse{Success: true, Data: updateMessageRequest, Error: ""}
	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 3 {
		http.Error(w, "Invalid path", http.StatusBadRequest)
		return
	}
	id, _ := strconv.Atoi(parts[2])
	message, _ := h.storage.GetByID(id)
	h.storage.Delete(id)
	response := models.APIResponse{Success: true, Data: message, Error: ""}
	h.writeJSON(w, http.StatusNoContent, response)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 4 {
		http.Error(w, "Invalid path", http.StatusBadRequest)
		return
	}
	code, _ := strconv.Atoi(parts[3])
	codeDescription := getHTTPStatusDescription(code)
	if codeDescription == "Unknown Status" {
		http.Error(w, "Invalid status code", http.StatusBadRequest)
		return
	}
	imageUrl := "https://http.cat/" + strconv.Itoa(code)
	httpStatusResponse := models.HTTPStatusResponse{StatusCode: code, ImageURL: imageUrl, Description: codeDescription}
	log.Println(httpStatusResponse)
	apiResponse := models.APIResponse{Success: true, Data: httpStatusResponse, Error: ""}
	h.writeJSON(w, http.StatusOK, apiResponse)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	healthCheckResponse := models.HealthCheckResponse{Status: "healthy",
		Message:       "API is running",
		Timestamp:     time.Now(),
		TotalMessages: h.storage.Count()}
	h.writeJSON(w, http.StatusOK, healthCheckResponse)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(data); err != nil {
		h.writeError(w, status, "Error encoding JSON")
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	apiResponse := models.APIResponse{Success: false, Data: "", Error: message}
	h.writeJSON(w, status, apiResponse)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	decoder := json.NewDecoder(r.Body)
	return decoder.Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	switch code {
	case 100:
		return "Continue"
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
	case 599:
		return "Some problem on server"
	}
	return "Unknown Status"
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
