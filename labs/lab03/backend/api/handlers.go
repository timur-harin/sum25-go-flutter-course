// api/handlers.go
package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"lab03-backend/models"
	"lab03-backend/storage"
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
	router := mux.NewRouter()
	router.Use(corsMiddleware)
	apiRouter := router.PathPrefix("/api").Subrouter()
	apiRouter.HandleFunc("/messages", h.GetMessages).Methods(http.MethodGet)
	apiRouter.HandleFunc("/messages", h.CreateMessage).Methods(http.MethodPost)
	apiRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods(http.MethodPut)
	apiRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods(http.MethodDelete)
	apiRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods(http.MethodGet)
	apiRouter.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	msgs := h.store.GetAll()
	response := models.APIResponse{Success: true, Data: msgs}
	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid request payload")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.store.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	response := models.APIResponse{Success: true, Data: msg}
	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid request payload")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.store.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, err.Error())
		}
		return
	}
	response := models.APIResponse{Success: true, Data: msg}
	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	if err := h.store.Delete(id); err != nil {
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
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	data := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("https://http.cat/%d", code),
		Description: getHTTPStatusDescription(code),
	}
	response := models.APIResponse{Success: true, Data: data}
	h.writeJSON(w, http.StatusOK, response)
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	health := map[string]interface{}{
		"status":         "ok",
		"message":        "API is running",
		"timestamp":      time.Now().UTC(),
		"total_messages": h.store.Count(),
	}
	h.writeJSON(w, http.StatusOK, health)
}

// writeJSON sets headers and writes JSON response
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		// Logging omitted
	}
}

// writeError writes an error response
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	resp := models.APIResponse{Success: false, Error: message}
	h.writeJSON(w, status, resp)
}

// parseJSON decodes JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	body := r.Body
	defer body.Close()
	decoder := json.NewDecoder(body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(dst)
}

// getHTTPStatusDescription returns standard HTTP status text
func getHTTPStatusDescription(code int) string {
	switch code {
	case http.StatusOK:
		return "OK"
	case http.StatusCreated:
		return "Created"
	case http.StatusNoContent:
		return "No Content"
	case http.StatusBadRequest:
		return "Bad Request"
	case http.StatusUnauthorized:
		return "Unauthorized"
	case http.StatusNotFound:
		return "Not Found"
	case http.StatusInternalServerError:
		return "Internal Server Error"
	default:
		return "Unknown Status"
	}
}

// corsMiddleware implements CORS handling
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
