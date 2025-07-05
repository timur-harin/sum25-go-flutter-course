package api

import (
	"encoding/json"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log/slog"
	"net/http"
	"strconv"
	"time"
	"github.com/gorilla/mux"
)

var logger = slog.Default()

// Handler holds the storage instance
type Handler struct {
	DB *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		DB: storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter().PathPrefix("/api").Subrouter()
	router.Use(corsMiddleware)
	router.Use(loggingMiddleware)
	router.Methods("GET").Path("/status/{code}").HandlerFunc(h.GetHTTPStatus)
	router.Methods("GET").Path("/health").HandlerFunc(h.HealthCheck)

	messageRouter := router.PathPrefix("/messages").Subrouter()
	messageRouter.Methods("GET").Path("").HandlerFunc(h.GetMessages)
	messageRouter.Methods("GET").Path("/{id}").HandlerFunc(h.GetMessageByID)
	messageRouter.Methods("POST").Path("").HandlerFunc(h.CreateMessage)
	messageRouter.Methods("PUT").Path("/{id}").HandlerFunc(h.UpdateMessage)
	messageRouter.Methods("DELETE").Path("/{id}").HandlerFunc(h.DeleteMessage)

	return router
}

func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.DB.GetAll()
	response := models.APIResponse{
		Success: true,
		Data:    messages,
	}
	h.writeJSON(w, http.StatusOK, response)
}

func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	err := h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	message, err := h.DB.Create(req.Username, req.Content)
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

func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}
	var req models.UpdateMessageRequest
	err = h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	message, err := h.DB.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrInvalidID {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to update message")
		}
		return
	}
	response := models.APIResponse{
		Success: true,
		Data:    message,
	}
	h.writeJSON(w, http.StatusOK, response)
}

func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}
	err = h.DB.Delete(id)
	if err != nil {
		if err == storage.ErrInvalidID {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to delete message")
		}
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	codeStr := vars["code"]
	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}
	responseResponse := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "https://http.cat/" + codeStr,
		Description: getHTTPStatusDescription(code),
	}
	responseBody := models.APIResponse{
		Success: true,
		Data:    responseResponse,
	}
	h.writeJSON(w, http.StatusOK, responseBody)
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	totalMessages := h.DB.Count()
	response := struct {
		Status        string `json:"status"`
		Message       string `json:"message"`
		Timestamp     string `json:"timestamp"`
		TotalMessages int    `json:"total_messages"`
	}{
		Status:        "ok",
		Message:       "API is running",
		Timestamp:     time.Now().Format(time.RFC3339),
		TotalMessages: totalMessages,
	}
	h.writeJSON(w, http.StatusOK, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	err := json.NewEncoder(w).Encode(data)
	if err != nil {
		logger.Warn("failed to encode data", "data", data)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	responseBody := models.APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, responseBody)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	err := json.NewDecoder(r.Body).Decode(dst)
	return err
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	description := http.StatusText(code)
	if description == "" {
		description = "Unknown Status"
	}
	return description
}

func (h *Handler) GetMessageByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid ID")
		return
	}
	message, err := h.DB.GetByID(id)
	if err != nil {
		if err == storage.ErrInvalidID {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to get message")
		}
		return
	}
	response := models.APIResponse{
		Success: true,
		Data:    message,
	}
	h.writeJSON(w, http.StatusOK, response)
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
		} else {
			next.ServeHTTP(w, r)
		}
	})
}

// Logging middleware logs incoming HTTP requests with method, path, and duration
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		duration := time.Since(start)
		logger.Info("request",
			"method", r.Method,
			"path", r.URL.Path,
			"duration", duration.String(),
		)
	})
}
