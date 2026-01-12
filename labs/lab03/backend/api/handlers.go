package api

import (
	"lab03-backend/storage"
	"net/http"

	"github.com/gorilla/mux"
	"encoding/json"
	"fmt"
	"log"
	"strconv"
	"time"
	"lab03-backend/models"
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
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()
	resp := models.APIResponse{Success: true, Data: messages}
	h.writeJSON(w, http.StatusOK, resp)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var request models.CreateMessageRequest
	if err := h.parseJSON(r, &request); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := request.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	message, err := h.storage.Create(request.Username, request.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	response := models.APIResponse{Success: true, Data: message}
	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	variables := mux.Vars(r)
	idStr := variables["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil || id <= 0 {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	var request models.UpdateMessageRequest
	if err := h.parseJSON(r, &request); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := request.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	message, err := h.storage.Update(id, request.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, err.Error())
		}
		return
	}
	response := models.APIResponse{Success: true, Data: message}
	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	variables := mux.Vars(r)
	idStr := variables["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil || id <= 0 {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	if err := h.storage.Delete(id); err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, err.Error())
		}
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	variables := mux.Vars(r)
	codeStr := variables["code"]
	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	description := getHTTPStatusDescription(code)
	url := fmt.Sprintf("https://http.cat/%d", code)
	statusResponse := models.HTTPStatusResponse{StatusCode: code, ImageURL: url, Description: description}
	response := models.APIResponse{Success: true, Data: statusResponse}
	h.writeJSON(w, http.StatusOK, response)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	data := map[string]interface{}{
		"status": "ok",
		"message": "API is running",
		"timestamp": time.Now(),
		"total_messages": h.storage.Count(),
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: data})
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Println("Failed to write JSON response:", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	errResponse := models.APIResponse{Success: false, Error: message}
	h.writeJSON(w, status, errResponse)
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
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
