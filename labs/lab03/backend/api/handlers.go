package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"

	"lab03-backend/models"
	"lab03-backend/storage"
)

type Handler struct {
	storage *storage.MemoryStorage
}

func NewHandler(st *storage.MemoryStorage) *Handler {
	return &Handler{storage: st}
}

func (h *Handler) SetupRoutes() *mux.Router {
	r := mux.NewRouter()
	r.Use(corsMiddleware)

	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/cat/{code}", h.GetStatusImage).Methods("GET") // <-- добавлено
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return r
}

func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	msgs := h.storage.GetAll()
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msgs})
}

func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON payload")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "failed to create message")
		return
	}
	h.writeJSON(w, http.StatusCreated, models.APIResponse{Success: true, Data: msg})
}

func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON payload")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Update(id, req.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msg})
}

func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	if err := h.storage.Delete(id); err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	code, err := strconv.Atoi(mux.Vars(r)["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	desc := http.StatusText(code)
	if desc == "" {
		desc = "Unknown Status"
	}
	statusResp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("http://localhost:8080/api/cat/%d", code),
		Description: desc,
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: statusResp})
}

// 🔽 Новая функция: прокси для https://http.cat/{code}
func (h *Handler) GetStatusImage(w http.ResponseWriter, r *http.Request) {
	code := mux.Vars(r)["code"]
	url := fmt.Sprintf("https://http.cat/%s", code)

	resp, err := http.Get(url)
	if err != nil {
		http.Error(w, "Failed to fetch image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		http.Error(w, "Image not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	w.WriteHeader(http.StatusOK)
	io.Copy(w, resp.Body)
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	health := struct {
		Status        string `json:"status"`
		Message       string `json:"message"`
		Timestamp     string `json:"timestamp"`
		TotalMessages int    `json:"total_messages"`
	}{
		Status:        "healthy",
		Message:       "API is running",
		Timestamp:     time.Now().Format(time.RFC3339),
		TotalMessages: h.storage.Count(),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	// Формируем JSON с плоской структурой, чтобы было поле "status" сверху
	resp := map[string]interface{}{
		"status":         health.Status,
		"message":        health.Message,
		"timestamp":      health.Timestamp,
		"total_messages": health.TotalMessages,
	}

	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "Failed to encode health response", http.StatusInternalServerError)
		return
	}
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}

func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, models.APIResponse{Success: false, Error: message})
}

func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
