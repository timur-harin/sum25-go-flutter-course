package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"lab03-backend/models"
	"lab03-backend/storage"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	store *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(store *storage.MemoryStorage) *Handler {
	return &Handler{store: store}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	r := mux.NewRouter()
	r.Use(corsMiddleware)

	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods(http.MethodGet)
	api.HandleFunc("/messages", h.CreateMessage).Methods(http.MethodPost)
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods(http.MethodPut)
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods(http.MethodDelete)
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods(http.MethodGet)
	api.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)

	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	msgs := h.store.GetAll()
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    msgs,
	})
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, _ := h.store.Create(req.Username, req.Content)
	h.writeJSON(w, http.StatusCreated, models.APIResponse{
		Success: true,
		Data:    msg,
	})
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid ID")
		return
	}
	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.store.Update(id, req.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    msg,
	})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid ID")
		return
	}
	if err := h.store.Delete(id); err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	code, err := strconv.Atoi(mux.Vars(r)["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	resp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("https://http.cat/%d", code),
		Description: getHTTPStatusDescription(code),
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    resp,
	})
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data: map[string]interface{}{
			"status":         "ok",
			"message":        "API is running",
			"timestamp":      time.Now().UTC(),
			"total_messages": h.store.Count(),
		},
	})
}

// writeJSON writes a JSON response
func (h *Handler) writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		// In production you might log this to a file or monitoring system
		http.Error(w, `{"success":false,"error":"encoding error"}`, http.StatusInternalServerError)
	}
}

// writeError writes an error response
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, models.APIResponse{
		Success: false,
		Error:   message,
	})
}

// parseJSON decodes JSON body into dst
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

// getHTTPStatusDescription returns a human-friendly status description
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

// corsMiddleware adds CORS headers and handles preflight
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
