package api

import (
	"encoding/json"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	Storage *storage.MemoryStorage // to store the messages
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	// Seems to be pretty useless utilization of a pointer
	// since "Handler" itself weights only 8 bytes
	return &Handler{
		Storage: storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	// RESTful design
	// Base: Lecture 3, slides 19-21

	// Needed to increase abstractions
	// when dealing with different routes and methods
	router := mux.NewRouter()

	// Setting the route prefix
	api := router.PathPrefix("/api").Subrouter()

	// Setting the handler functions

	// Gets the related message (Method: GET)
	api.Handle("/messages", corsMiddleware(http.HandlerFunc(h.GetMessages))).Methods("GET")
	// Creates a message (Method: POST)
	api.Handle("/messages", corsMiddleware(http.HandlerFunc(h.CreateMessage))).Methods("POST")
	// Updates the message (Method: PUT)
	// "id" is used as a unique number of a message that is needed to be updated
	api.Handle("/messages/{id}", corsMiddleware(http.HandlerFunc(h.UpdateMessage))).Methods("PUT")
	// Deletes the message using its ID (Method: DELETE)
	api.Handle("/messages/{id}", corsMiddleware(http.HandlerFunc(h.DeleteMessage))).Methods("DELETE")
	// Gets the image with a cat for a requested HTTP status code (Method: GET)
	api.Handle("/status/{code}", corsMiddleware(http.HandlerFunc(h.GetHTTPStatus))).Methods("GET")
	// Gets the "health" status JSON (Method: GET)
	api.Handle("/health", corsMiddleware(http.HandlerFunc(h.HealthCheck))).Methods("GET")

	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// Lecture 3, slide: 19
	path := r.URL.Path
	parts := strings.Split(path, "/")

	// Must be "/api/messages/"
	if len(parts) != 3 {
		h.writeError(w, 400, "Invalid path")
		return
	}

	// Get all the messages stored
	msgs := h.Storage.GetAll()

	// Create the successful API response
	resp := models.APIResponse{
		Success: true,
		Data:    msgs,
	}

	// Write the result to the response JSON
	h.writeJSON(w, 200, resp)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	// Lecture 3, slide: 19
	path := r.URL.Path
	parts := strings.Split(path, "/")

	// Must be "/api/messages/"
	if len(parts) != 3 {
		h.writeError(w, 400, "Invalid path")
		return
	}

	// Parse the request
	var crtReq models.CreateMessageRequest
	parseErr := h.parseJSON(r, &crtReq)
	if parseErr != nil {
		h.writeError(w, 400, "Error while parsing the JSON")
		return
	}

	// Validate the request
	validateErr := crtReq.Validate()
	if validateErr != nil {
		h.writeError(w, 400, "Invalid request: "+validateErr.Error())
		return
	}

	// Create a message
	msg, crtErr := h.Storage.Create(crtReq.Username, crtReq.Content)
	if crtErr != nil {
		h.writeError(w, 400, "Failed to create the message")
		return
	}

	// Create the successfull API response
	resp := models.APIResponse{
		Success: true,
		Data:    msg.Content,
	}

	// Send the result JSON
	h.writeJSON(w, 201, resp)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	// Lecture 3, slide: 19
	path := r.URL.Path
	parts := strings.Split(path, "/")

	// Must be "/api/messages/{id}/"
	if len(parts) != 4 {
		h.writeError(w, 400, "Invalid path")
		return
	}

	// Parse integer -> get the ID
	id, parseErr := strconv.Atoi(parts[3]) // {id}
	if parseErr != nil {
		h.writeError(w, 400, "ID must be an integer value")
		return
	}

	// Parse the request
	var updReq models.UpdateMessageRequest
	parseErr = h.parseJSON(r, &updReq)
	if parseErr != nil {
		h.writeError(w, 400, "Error while parsing the JSON")
		return
	}

	// Validate the request
	validateErr := updReq.Validate()
	if validateErr != nil {
		h.writeError(w, 400, "Invalid request: "+validateErr.Error())
		return
	}

	// Update the message
	msg, updErr := h.Storage.Update(id, updReq.Content)
	if updErr != nil {
		h.writeError(w, 400, "Failed to update the message with ID: "+strconv.Itoa(id))
		return
	}

	// Create the successfull API response
	resp := models.APIResponse{
		Success: true,
		Data:    msg.Content,
	}

	// Send the result JSON
	h.writeJSON(w, http.StatusOK, resp)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// Lecture 3, slide: 19
	path := r.URL.Path
	parts := strings.Split(path, "/")

	// Must be "/api/messages/{id}/"
	if len(parts) != 4 {
		h.writeError(w, 400, "Invalid path")
		return
	}

	// Parse integer -> get the ID
	id, parseErr := strconv.Atoi(parts[3]) // {id}
	if parseErr != nil {
		h.writeError(w, 400, "ID must be an integer value")
		return
	}

	// Delete the message
	delErr := h.Storage.Delete(id)
	if delErr != nil {
		// Log the error
		log.Printf("h.Storage.Delete() failed: %s", delErr.Error())
		h.writeError(w, 400, "Could not delete the message: "+delErr.Error())
		return
	}

	// Write the response (code: 204)
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// Lecture 3, slide: 19
	path := r.URL.Path
	parts := strings.Split(path, "/")

	// Must be "/api/status/{code}/"
	if len(parts) != 4 {
		h.writeError(w, 400, "Invalid path")
		return
	}

	// Parse integer
	neededCode, parseErr := strconv.Atoi(parts[3]) // {code}
	if parseErr != nil {
		h.writeError(w, 400, "Status code must be an integer value")
		return
	}

	// Check for the requested code to be valid
	if neededCode < 100 || neededCode > 500 {
		h.writeError(w, 400, "Status code must be in range [100, 500]")
		return
	}

	// Compose the result response JSON body
	imgUrl := "https://http.cat/" + strconv.Itoa(neededCode)
	res := models.HTTPStatusResponse{
		StatusCode:  neededCode,
		ImageURL:    imgUrl,
		Description: getHTTPStatusDescription(neededCode),
	}

	// Result response JSON
	resp := models.APIResponse{
		Success: true,
		Data:    res,
	}

	// Write the result JSON
	h.writeJSON(w, http.StatusOK, resp)
}

// Represents a JSON server health check response
type Healthcheck_t struct {
	Status string    `json:"status"`
	Msg    string    `json:"message"`
	Tm     time.Time `json:"timestamp"`
	MsgCnt uint64    `json:"total_messages"`
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	// Create the JSON response body
	hchkr := Healthcheck_t{
		Status: "ok",
		Msg:    "API is running",
		Tm:     time.Now(),
		MsgCnt: uint64(h.Storage.Count()),
	}

	// Write JSON response with status code 200
	h.writeJSON(w, 200, hchkr)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// Set the response header
	w.Header().Set("Content-type", "application/json")
	// Write the status code
	w.WriteHeader(status)
	// Encode the data
	enc_err := json.NewEncoder(w).Encode(data)
	if enc_err != nil { // Encoding error met
		// Log the error in ~ Linux style
		log.Printf("writeJSON() failed: %s\n", enc_err.Error())
		// Send 500: Internal Server Error
		http.Error(w, getHTTPStatusDescription(500), 500)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// Create a fail APIResponse
	err_resp := models.APIResponse{
		Success: false,
		Error:   message,
	}

	// Write the JSON response with the err_resp structure
	h.writeJSON(w, status, err_resp)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// New JSON decoder from the request ("r") body
	decoder := json.NewDecoder(r.Body)
	// Decode into the destination interface
	return decoder.Decode(dst) // return the result of "Decode() - error"
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	// Some status codes
	switch code {
	case 100:
		return "Continue"
	case 200:
		return "OK"
	case 400:
		return "Bad Request"
	case 404:
		return "Not Found"
	case 418:
		return "I'm a teapot"
	case 500:
		return "Internal Server Error"
	}

	return "Unknown Status"
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	// Base: Lecture 3, slide: 21
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Setting the headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Send the CORS headers
		if r.Method == "OPTIONS" {
			// Typically used for CORE-requests
			// instead of 200 OK
			w.WriteHeader(http.StatusNoContent)
			return
		}

		// OK -> go to the main "processor"
		next.ServeHTTP(w, r)
	})
}
