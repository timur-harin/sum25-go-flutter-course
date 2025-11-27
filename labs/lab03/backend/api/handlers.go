package api

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"lab03-backend/storage"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	store *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(store *storage.MemoryStorage) *Handler {
	return &Handler{
		store: store,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()
	router.Use(corsMiddleware)

	api := router.PathPrefix("/api").Subrouter()

	api.HandleFunc("/messages", h.GetMessages).Methods(http.MethodGet)
	api.HandleFunc("/messages", h.CreateMessage).Methods(http.MethodPost)
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods(http.MethodPut)
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods(http.MethodDelete)
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods(http.MethodGet)
	api.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)

	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.store.GetAllMessages()

	resp := struct {
		Success bool        `json:"success"`
		Data    interface{} `json:"data"`
	}{
		Success: true,
		Data:    messages,
	}

	h.writeJSON(w, http.StatusOK, resp)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Username string `json:"username"`
		Content  string `json:"content"`
	}

	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON body")
		return
	}

	if req.Username == "" || req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "Username and content must not be empty")
		return
	}

	msg, err := h.store.CreateMessage(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message")
		return
	}

	resp := struct {
		Success bool        `json:"success"`
		Data    interface{} `json:"data"`
	}{
		Success: true,
		Data:    msg,
	}

	h.writeJSON(w, http.StatusCreated, resp)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing message ID")
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	var req struct {
		Content string `json:"content"`
	}

	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON body")
		return
	}

	if req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "Content must not be empty")
		return
	}

	updatedMsg, err := h.store.UpdateMessage(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to update message")
		}
		return
	}

	resp := struct {
		Success bool        `json:"success"`
		Data    interface{} `json:"data"`
	}{
		Success: true,
		Data:    updatedMsg,
	}

	h.writeJSON(w, http.StatusOK, resp)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing message ID")
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	err = h.store.DeleteMessage(id)
	if err != nil {
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
	codeStr, ok := vars["code"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing status code")
		return
	}
	code, err := strconv.Atoi(codeStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Status code must be between 100 and 599")
		return
	}

	respData := struct {
		StatusCode  int    `json:"status_code"`
		ImageURL    string `json:"image_url"`
		Description string `json:"description"`
	}{
		StatusCode:  code,
		ImageURL:    "https://http.cat/" + codeStr,
		Description: getHTTPStatusDescription(code),
	}

	resp := struct {
		Success bool        `json:"success"`
		Data    interface{} `json:"data"`
	}{
		Success: true,
		Data:    respData,
	}

	h.writeJSON(w, http.StatusOK, resp)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	resp := struct {
		Status        string `json:"status"`
		Message       string `json:"message"`
		Timestamp     string `json:"timestamp"`
		TotalMessages int    `json:"total_messages"`
	}{
		Status:        "ok",
		Message:       "API is running",
		Timestamp:     time.Now().Format(time.RFC3339),
		TotalMessages: h.store.CountMessages(),
	}

	h.writeJSON(w, http.StatusOK, resp)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Failed to write JSON response: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	resp := struct {
		Success bool   `json:"success"`
		Error   string `json:"error"`
	}{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, resp)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	defer r.Body.Close()
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
	case 418:
		return "I'm a teapot"
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
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
