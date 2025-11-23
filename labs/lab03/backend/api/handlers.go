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

type Handler struct {
	storage *storage.MemoryStorage
}

func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		storage: storage,
	}
}

func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()

	api := router.PathPrefix("/api").Subrouter()

	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id:[0-9]+}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id:[0-9]+}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code:[0-9]+}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	api.HandleFunc("/cat/{code:[0-9]+}", h.GetCatImage).Methods("GET")

	// Apply CORS middleware to the router
	router.Use(corsMiddleware)

	return router
}

func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()

	response := models.APIResponse{
		Success: true,
		Data:    messages,
	}

	h.writeJSON(w, http.StatusOK, response)
}

func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest

	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}
	defer r.Body.Close()

	validation := req.Validate()
	if validation != nil {
		h.writeError(w, http.StatusBadRequest, validation.Error())
		return
	}

	message, err := h.storage.Create(
		req.Username,
		req.Content,
	)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
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
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	var updReq models.UpdateMessageRequest
	if err := h.parseJSON(r, &updReq); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}

	if updReq.Content == "" {
		h.writeError(w, http.StatusBadRequest, "Message content cannot be Empty")
		return
	}

	updMsg, err := h.storage.Update(id, updReq.Content)

	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.writeJSON(w, http.StatusOK, updMsg)
}

func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}
	deleteErr := h.storage.Delete(id)

	if deleteErr != nil {
		h.writeError(w, http.StatusBadRequest, deleteErr.Error())
		return
	}

	h.writeJSON(w, http.StatusNoContent, nil)
}

func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Status code must be between 100 and 599")
		return
	}
	description := getHTTPStatusDescription(code)

	statusResponse := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("http://localhost:8080/api/cat/%d", code),
		Description: description,
	}

	response := models.APIResponse{
		Success: true,
		Data:    statusResponse,
	}

	h.writeJSON(w, http.StatusOK, response)
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	responce := map[string]interface{}{
		"status":         "healthy",
		"message":        "API is running",
		"timestamp":      time.Now().Format(time.RFC3339),
		"total_messages": len(h.storage.GetAll()),
	}

	h.writeJSON(w, http.StatusOK, responce)
}

func (h *Handler) GetCatImage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Status code must be between 100 and 599")
		return
	}

	catURL := fmt.Sprintf("https://http.cat/%d", code)
	resp, err := http.Get(catURL)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to fetch cat image")
		return
	}
	defer resp.Body.Close()

	origin := r.Header.Get("Origin")
	if origin == "http://localhost:3000" {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	} else {
		w.Header().Set("Access-Control-Allow-Origin", "*")
	}

	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Content-Length", resp.Header.Get("Content-Length"))
	w.WriteHeader(resp.StatusCode)

	io.Copy(w, resp.Body)
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if data != nil {
		if err := json.NewEncoder(w).Encode(data); err != nil {
			log.Printf("Error encoding JSON response: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
		}
	}
}

func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	response := map[string]interface{}{
		"success": false,
		"error":   message,
	}
	h.writeJSON(w, status, response)
}

func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	decoder := json.NewDecoder(r.Body)
	return decoder.Decode(dst)
}

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

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin == "http://localhost:3000" {
			w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		} else {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
