package api

import (
	"encoding/json"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

// APIResponse defines the standard response structure
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// CreateMessageRequest defines the request structure for creating messages
type CreateMessageRequest struct {
	Username string `json:"username"`
	Content  string `json:"content"`
}

// UpdateMessageRequest defines the request structure for updating messages
type UpdateMessageRequest struct {
	Content string `json:"content"`
}

// HTTPStatusResponse defines the response structure for HTTP status endpoint
type HTTPStatusResponse struct {
	StatusCode  int    `json:"status_code"`
	ImageURL    string `json:"image_url"`
	Description string `json:"description"`
}

// HealthResponse defines the response structure for health check endpoint
type HealthResponse struct {
	Status        string `json:"status"`
	Message       string `json:"message"`
	Timestamp     string `json:"timestamp"`
	TotalMessages int    `json:"total_messages"`
}

type Handler struct {
	storage *storage.MemoryStorage
}

func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage: storage}
}

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

func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages, err := h.storage.GetAll()
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "could not get messages")
		return
	}

	h.writeJSON(w, http.StatusOK, APIResponse{
		Success: true,
		Data:    messages,
	})
}

func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Username == "" || req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "username and content are required")
		return
	}

	message, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "could not create message")
		return
	}

	h.writeJSON(w, http.StatusCreated, APIResponse{
		Success: true,
		Data:    message,
	})
}

func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}

	var req UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "content is required")
		return
	}

	message, err := h.storage.Update(id, req.Content)
	if err != nil {
		if err.Error() == "message not found" {
			h.writeError(w, http.StatusNotFound, "message not found")
			return
		}
		h.writeError(w, http.StatusInternalServerError, "could not update message")
		return
	}

	h.writeJSON(w, http.StatusOK, APIResponse{
		Success: true,
		Data:    message,
	})
}

func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}

	if err := h.storage.Delete(id); err != nil {
		if err.Error() == "message not found" {
			h.writeError(w, http.StatusNotFound, "message not found")
			return
		}
		h.writeError(w, http.StatusInternalServerError, "could not delete message")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	codeStr := vars["code"]
	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}

	description := getHTTPStatusDescription(code)
	response := HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "https://http.cat/" + strconv.Itoa(code),
		Description: description,
	}

	h.writeJSON(w, http.StatusOK, APIResponse{
		Success: true,
		Data:    response,
	})
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	count := h.storage.Count()
	healthResponse := HealthResponse{
		Status:        "ok",
		Message:       "API is running",
		Timestamp:     time.Now().Format(time.RFC3339),
		TotalMessages: count,
	}

	h.writeJSON(w, http.StatusOK, APIResponse{
		Success: true,
		Data:    healthResponse,
	})
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error writing JSON response: %v", err)
	}
}

func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, APIResponse{
		Success: false,
		Error:   message,
	})
}

func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

func getHTTPStatusDescription(code int) string {
	switch code {
	case 100:
		return "Continue"
	case 101:
		return "Switching Protocols"
	case 200:
		return "OK"
	case 201:
		return "Created"
	case 202:
		return "Accepted"
	case 204:
		return "No Content"
	case 301:
		return "Moved Permanently"
	case 302:
		return "Found"
	case 304:
		return "Not Modified"
	case 400:
		return "Bad Request"
	case 401:
		return "Unauthorized"
	case 403:
		return "Forbidden"
	case 404:
		return "Not Found"
	case 405:
		return "Method Not Allowed"
	case 500:
		return "Internal Server Error"
	case 501:
		return "Not Implemented"
	case 502:
		return "Bad Gateway"
	case 503:
		return "Service Unavailable"
	default:
		return "Unknown Status"
	}
}

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
