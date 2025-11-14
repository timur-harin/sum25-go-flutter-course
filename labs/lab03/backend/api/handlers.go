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
	r := mux.NewRouter()
	r.Use(corsMiddleware)
	api := r.PathPrefix("/api").Subrouter()

	api.HandleFunc("/{any:.*}", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}).Methods(http.MethodOptions)

	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/cat/{code}", h.GetHTTPCatImage).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: messages})
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message")
		return
	}

	h.writeJSON(w, http.StatusCreated, models.APIResponse{Success: true, Data: msg})
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.storage.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to update message")
		}
		return
	}

	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msg})
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
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to delete message")
		}
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
		ImageURL:    fmt.Sprintf("http://localhost:8888/api/cat/%d", code), // Use our proxy
		Description: getHTTPStatusDescription(code),
	}

	response := models.APIResponse{
		Success: true,
		Data:    statusResponse,
	}

	h.writeJSON(w, http.StatusOK, response)
}

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
	response := struct {
		Status        string    `json:"status"`
		Message       string    `json:"message"`
		Timestamp     time.Time `json:"timestamp"`
		TotalMessages int       `json:"total_messages"`
	}{
		Status:        "healthy",
		Message:       "API is running",
		Timestamp:     time.Now(),
		TotalMessages: h.storage.Count(),
	}

	h.writeJSON(w, http.StatusOK, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, models.APIResponse{Success: false, Error: message})
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	defer r.Body.Close()
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
		log.Printf("Got request: %s %s\n", r.Method, r.URL.Path)
		origin := r.Header.Get("Origin")
		if origin == "http://localhost:3000" || origin == "http://127.0.0.1:3000" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization")

		if r.Method == "OPTIONS" {
			log.Println("Handling OPTIONS request")
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
