package chatcore

import (
	"context"
	"log"
	"sync"
	"time"
)

// Message represents a chat message
type Message struct {
	Sender    string
	Recipient string
	Content   string
	Broadcast bool
	Timestamp int64
}

// Broker handles message routing between users
type Broker struct {
	ctx        context.Context
	input      chan Message            // Fan-in: all messages come here first
	users      map[string]chan Message // userID -> receiving channel
	usersMutex sync.RWMutex            // Protects the users map
	done       chan struct{}           // Signals that the Run loop has terminated
}

// NewBroker creates a new message broker
func NewBroker(ctx context.Context) *Broker {
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker's main event loop in a goroutine
func (b *Broker) Run() {
	defer close(b.done) // Signal shutdown is complete when loop exits

	for {
		select {
		case msg := <-b.input:
			// Set timestamp if not already set
			if msg.Timestamp == 0 {
				msg.Timestamp = time.Now().UnixNano()
			}

			if msg.Broadcast {
				b.broadcastMessage(msg)
			} else {
				b.sendPrivateMessage(msg)
			}

		case <-b.ctx.Done():
			// Context was cancelled, shut down the broker
			log.Println("Broker shutting down...")
			return
		}
	}
}

// broadcastMessage sends a message to all registered users
func (b *Broker) broadcastMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	for id, userChan := range b.users {
		// Use a non-blocking send to prevent a slow client
		// from blocking the entire broker.
		select {
		case userChan <- msg:
		default:
			log.Printf("User %s's channel is full. Dropping message.", id)
		}
	}
}

// sendPrivateMessage sends a message to a specific recipient
func (b *Broker) sendPrivateMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if userChan, ok := b.users[msg.Recipient]; ok {
		// Non-blocking send
		select {
		case userChan <- msg:
		default:
			log.Printf("User %s's channel is full. Dropping private message from %s.", msg.Recipient, msg.Sender)
		}
	}
}

// SendMessage sends a message into the broker's input channel.
// This is the main entry point for external components.
func (b *Broker) SendMessage(msg Message) error {
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		// Return the context's error (e.g., context.Canceled)
		return b.ctx.Err()
	}
}

// RegisterUser adds a user and their channel to the broker's registry
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	// Closing the channel signals the user's goroutine to stop listening
	if ch, ok := b.users[userID]; ok {
		// It's good practice to check if the channel is already closed
		// to prevent a panic, though in this design it's unlikely.
		select {
		case <-ch:
			// already closed
		default:
			close(ch)
		}
	}
	delete(b.users, userID)
}
