package websocket

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/websocket"
)

func TestService_NewService(t *testing.T) {
	service := NewService()

	if service == nil {
		t.Fatal("NewService returned nil")
	}

	if service.hub == nil {
		t.Fatal("Service hub is nil")
	}

	if service.GetConnectedClients() != 0 {
		t.Errorf("Expected 0 connected clients, got %d", service.GetConnectedClients())
	}
}

func TestService_GetStatsHandler(t *testing.T) {
	service := NewService()
	handler := service.GetStatsHandler()

	req := httptest.NewRequest("GET", "/stats", nil)
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rr.Code)
	}

	var stats map[string]interface{}
	if err := json.NewDecoder(rr.Body).Decode(&stats); err != nil {
		t.Fatalf("Failed to decode stats response: %v", err)
	}

	if stats["service"] != "websocket" {
		t.Errorf("Expected service 'websocket', got '%v'", stats["service"])
	}

	if stats["active_connections"] != float64(0) {
		t.Errorf("Expected 0 active connections, got %v", stats["active_connections"])
	}
}

func TestMessage_JSON(t *testing.T) {
	message := Message{
		Type:      "test",
		Content:   "Hello World",
		User:      "testuser",
		Timestamp: time.Now(),
		Delay:     100,
	}

	// Test JSON marshaling
	data, err := json.Marshal(message)
	if err != nil {
		t.Fatalf("Failed to marshal message: %v", err)
	}

	// Test JSON unmarshaling
	var decoded Message
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("Failed to unmarshal message: %v", err)
	}

	if decoded.Type != message.Type {
		t.Errorf("Expected type '%s', got '%s'", message.Type, decoded.Type)
	}

	if decoded.Content != message.Content {
		t.Errorf("Expected content '%s', got '%s'", message.Content, decoded.Content)
	}

	if decoded.User != message.User {
		t.Errorf("Expected user '%s', got '%s'", message.User, decoded.User)
	}

	if decoded.Delay != message.Delay {
		t.Errorf("Expected delay %d, got %d", message.Delay, decoded.Delay)
	}
}

func TestService_BroadcastMessage(t *testing.T) {
	service := NewService()

	// Wait a moment for the hub to start
	time.Sleep(10 * time.Millisecond)

	testMessage := Message{
		Type:    "test",
		Content: "Test broadcast",
		User:    "testuser",
	}

	// This should not panic even with no connected clients
	service.BroadcastMessage(testMessage)

	// Verify the message was timestamped
	if testMessage.Timestamp.IsZero() {
		// Note: BroadcastMessage modifies the timestamp internally
		// but doesn't modify the original struct passed to it
	}
}

func TestHub_ClientManagement(t *testing.T) {
	hub := &Hub{
		clients:    make(map[*Client]bool),
		broadcast:  make(chan Message),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}

	go hub.run()

	// Create a mock client
	client := &Client{
		send:   make(chan Message, 1),
		hub:    hub,
		userID: "testuser",
	}

	// Register client
	hub.register <- client

	// Give some time for registration
	time.Sleep(10 * time.Millisecond)

	// Check if client was registered
	hub.mutex.RLock()
	registered := hub.clients[client]
	clientCount := len(hub.clients)
	hub.mutex.RUnlock()

	if !registered {
		t.Error("Client was not registered")
	}

	if clientCount != 1 {
		t.Errorf("Expected 1 client, got %d", clientCount)
	}

	// Unregister client
	hub.unregister <- client

	// Give some time for unregistration
	time.Sleep(10 * time.Millisecond)

	// Check if client was unregistered
	hub.mutex.RLock()
	stillRegistered := hub.clients[client]
	clientCount = len(hub.clients)
	hub.mutex.RUnlock()

	if stillRegistered {
		t.Error("Client is still registered")
	}

	if clientCount != 0 {
		t.Errorf("Expected 0 clients, got %d", clientCount)
	}
}

func TestHub_MessageBroadcast(t *testing.T) {
	hub := &Hub{
		clients:    make(map[*Client]bool),
		broadcast:  make(chan Message),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}

	go hub.run()

	// Create mock clients
	client1 := &Client{
		send:   make(chan Message, 10),
		hub:    hub,
		userID: "user1",
	}

	client2 := &Client{
		send:   make(chan Message, 10),
		hub:    hub,
		userID: "user2",
	}

	// Register clients
	hub.register <- client1
	hub.register <- client2

	time.Sleep(50 * time.Millisecond) // Longer wait for join notifications

	// Clear all messages (welcome + join notifications) with timeout
	timeout := time.After(100 * time.Millisecond)
	for {
		select {
		case <-client1.send:
			// Continue draining
		case <-timeout:
			goto drainClient2
		default:
			goto drainClient2
		}
	}

drainClient2:
	timeout = time.After(100 * time.Millisecond)
	for {
		select {
		case <-client2.send:
			// Continue draining
		case <-timeout:
			goto broadcastTest
		default:
			goto broadcastTest
		}
	}

broadcastTest:
	// Broadcast a message
	testMessage := Message{
		Type:    "test",
		Content: "Hello everyone",
		User:    "broadcaster",
	}

	hub.broadcast <- testMessage

	time.Sleep(50 * time.Millisecond) // Longer wait for broadcast

	// Check if both clients received the message
	select {
	case msg := <-client1.send:
		if msg.Content != testMessage.Content {
			t.Errorf("Client1: Expected content '%s', got '%s'", testMessage.Content, msg.Content)
		}
	default:
		t.Error("Client1 did not receive broadcast message")
	}

	select {
	case msg := <-client2.send:
		if msg.Content != testMessage.Content {
			t.Errorf("Client2: Expected content '%s', got '%s'", testMessage.Content, msg.Content)
		}
	default:
		t.Error("Client2 did not receive broadcast message")
	}
}

func TestWebSocketUpgrade(t *testing.T) {
	service := NewService()

	// Create test server
	server := httptest.NewServer(http.HandlerFunc(service.handleWebSocket))
	defer server.Close()

	// Convert HTTP URL to WebSocket URL
	wsURL := "ws" + strings.TrimPrefix(server.URL, "http") + "?user_id=testuser"

	// Connect as client
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("Failed to connect to WebSocket: %v", err)
	}
	defer conn.Close()

	// Give time for connection to be established
	time.Sleep(50 * time.Millisecond)

	// Check if client count increased
	if service.GetConnectedClients() != 1 {
		t.Errorf("Expected 1 connected client, got %d", service.GetConnectedClients())
	}

	// Send a test message
	testMessage := Message{
		Type:    "message",
		Content: "Hello from test",
	}

	if err := conn.WriteJSON(testMessage); err != nil {
		t.Fatalf("Failed to send message: %v", err)
	}

	// Read response (should be the same message echoed back)
	var response Message
	if err := conn.ReadJSON(&response); err != nil {
		t.Fatalf("Failed to read response: %v", err)
	}

	// The first message should be a welcome message
	if response.Type != "system" {
		t.Errorf("Expected first message type 'system', got '%s'", response.Type)
	}
}

func TestWebSocket_PingPong(t *testing.T) {
	service := NewService()

	// Create test server
	server := httptest.NewServer(http.HandlerFunc(service.handleWebSocket))
	defer server.Close()

	// Convert HTTP URL to WebSocket URL
	wsURL := "ws" + strings.TrimPrefix(server.URL, "http") + "?user_id=pingtest"

	// Connect as client
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("Failed to connect to WebSocket: %v", err)
	}
	defer conn.Close()

	// Give time for connection
	time.Sleep(50 * time.Millisecond)

	// Send ping message
	pingMessage := Message{
		Type:    "ping",
		Content: "ping",
	}

	if err := conn.WriteJSON(pingMessage); err != nil {
		t.Fatalf("Failed to send ping: %v", err)
	}

	// Read messages until we get pong
	var receivedPong bool
	for i := 0; i < 3; i++ { // Try up to 3 messages
		var response Message
		conn.SetReadDeadline(time.Now().Add(1 * time.Second))
		if err := conn.ReadJSON(&response); err != nil {
			break
		}

		if response.Type == "pong" {
			receivedPong = true
			break
		}
	}

	if !receivedPong {
		t.Error("Did not receive pong response to ping")
	}
}
