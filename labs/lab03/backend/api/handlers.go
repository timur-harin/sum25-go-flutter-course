package api

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"lab03-backend/models"
	"lab03-backend/storage"
)

/* --------------------------- структура --------------------------- */

// Handler holds the storage instance
type Handler struct {
	store *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(store *storage.MemoryStorage) *Handler {
	return &Handler{store: store}
}

/* --------------------------- маршруты --------------------------- */

func (h *Handler) SetupRoutes() *mux.Router {
	r := mux.NewRouter()
	r.Use(corsMiddleware) // глобальный CORS

	api := r.PathPrefix("/api").Subrouter()

	api.HandleFunc("/messages", h.GetMessages).Methods(http.MethodGet)
	api.HandleFunc("/messages", h.CreateMessage).Methods(http.MethodPost)
	api.HandleFunc("/messages/{id:[0-9]+}", h.UpdateMessage).Methods(http.MethodPut)
	api.HandleFunc("/messages/{id:[0-9]+}", h.DeleteMessage).Methods(http.MethodDelete)

	api.HandleFunc("/status/{code:[0-9]+}", h.GetHTTPStatus).Methods(http.MethodGet)
	api.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)

	// OPTIONS pre-flight
	api.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}).Methods(http.MethodOptions)

	return r
}

/* ------------------------- /api/messages ------------------------- */

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, _ *http.Request) {
	msgs, err := h.store.GetAll(), error(nil)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "failed to fetch messages")
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msgs})
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

	msg, err := h.store.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "failed to create message")
		return
	}
	h.writeJSON(w, http.StatusCreated, models.APIResponse{Success: true, Data: msg})
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id")
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
		if errors.Is(err, storage.ErrNotFound) {
			h.writeError(w, http.StatusNotFound, "message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "failed to update message")
		}
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msg})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.store.Delete(id); err != nil {
		if errors.Is(err, storage.ErrNotFound) {
			h.writeError(w, http.StatusNotFound, "message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "failed to delete message")
		}
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

/* ----------------------- /api/status/{code} ----------------------- */

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	code, err := strconv.Atoi(mux.Vars(r)["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "status code must be 100–599")
		return
	}

	resp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "https://http.cat/" + strconv.Itoa(code),
		Description: getHTTPStatusDescription(code),
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: resp})
}

/* ---------------------------- /api/health -------------------------- */

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, _ *http.Request) {
	payload := map[string]interface{}{
		"status":         "ok",
		"message":        "API is running",
		"timestamp":      time.Now().UTC(),
		"total_messages": h.store.Count(),
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: payload})
}

/* --------------------------- helpers --------------------------- */

func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("json encode error: %v", err)
	}
}

func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, models.APIResponse{Success: false, Error: message})
}

func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	defer r.Body.Close()
	limited := io.LimitReader(r.Body, 1<<20) // 1 MB
	return json.NewDecoder(limited).Decode(dst)
}

// getHTTPStatusDescription returns a short description for popular codes
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

/* ----------------------------- CORS ----------------------------- */

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
