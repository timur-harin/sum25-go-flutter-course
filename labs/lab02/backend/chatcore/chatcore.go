package chatcore

import (
	"context"
	"sync"
)

// Message represents a chat message
// Sender, Recipient, Content, Broadcast, Timestamp

type Message struct {
	Sender    string
	Recipient string
	Content   string
	Broadcast bool
	Timestamp int64
}

// Broker handles message routing between users
// Contains context, input channel, user registry, mutex, done channel

type Broker struct {
	ctx        context.Context
	input      chan Message            // Incoming messages
	users      map[string]chan Message // userID -> receiving channel
	usersMutex sync.RWMutex            // Protects users map
	done       chan struct{}           // For shutdown
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

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	for {
		select {
		case <-b.ctx.Done(): // Job must be terminated
			close(b.done)
			return

		case msg := <-b.input: // Got message
			b.SendMessage(msg) // Send message
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {

	if msg.Broadcast { // Send to everyone

		b.usersMutex.RLock() // Lock for all operations
		for _, msgBuf := range b.users {
			// Since channels are thread-safe
			msgBuf <- msg // Write to the user messages buffer
		}
		b.usersMutex.RUnlock() // Job is done -> Unlock

	} else { // Send to a particular person

		// Check if the user exists
		// Purpose: to avoid panic
		b.usersMutex.RLock() // Lock for read operations
		_, found := b.users[msg.Recipient]
		if found { // User does exist
			// Since channels are thread-safe
			b.users[msg.Recipient] <- msg // Write the message
		}
		b.usersMutex.RUnlock() // User is checked -> Unlock

	}

	return b.ctx.Err() // Since no explanation on error messages was given
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()    // Lock for all operations
	b.users[userID] = recv // Create a channel for messages
	b.usersMutex.Unlock()  // Job is done -> Unlock
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()     // Lock for all operations
	delete(b.users, userID) // Create a channel for messages
	b.usersMutex.Unlock()   // Job is done -> Unlock
}
