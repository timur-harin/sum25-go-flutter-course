package chatcore

import (
	"context"
	"errors"
	"sync"
	"time"
)

// Message represents a chat message with Sender, Recipient, Content, Broadcast, Timestamp parameters
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
	ctx        context.Context         // Context to manage the lifecycle
	input      chan Message            // Incoming messages
	users      map[string]chan Message // userID -> receiving channel
	usersMutex sync.RWMutex            // Protects users map
	done       chan struct{}           // For shutdown
}

// NewBroker creates a new message broker
func NewBroker(ctx context.Context) *Broker {
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100), // Creating a channel with a buffer for 100 messages
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	go func() {
		for {
			select {
			// If there is sygnal for shutdown, then we do shutdown
			case <-b.ctx.Done():
				close(b.done)
				return
			// If new message came
			case msg := <-b.input:
				// Data reading is allowed, but modification is not
				b.usersMutex.RLock()
				// If the message is public, for all
				if msg.Broadcast {
					// Send to all users including sender
					for _, ch := range b.users {
						select {
						case ch <- msg:
						default:
							// Skip if channel is full
						}
					}
				} else { // If the message is private, not for all
					// Finding recipient
					if ch, ok := b.users[msg.Recipient]; ok {
						select {
						case ch <- msg:
						default:
							// Skip if channel is full
						}
					}
				}
				// Now there is opportunity to change the data in b.users
				b.usersMutex.RUnlock()
			}
		}
	}()
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker shutting down")
	case <-b.done:
		return errors.New("broker closed")
	default:
	}

	// If no date, then pase current one
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
	}

	select {
	// Successful sending message
	case b.input <- msg:
		return nil
	// Channel is closed, broker should shutdown
	case <-b.ctx.Done():
		return errors.New("broker shutting down")
	// Channel was full during one second
	case <-time.After(time.Second):
		return errors.New("broker too busy")
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// No opportunity to change data in list of users
	b.usersMutex.Lock()
	// The list will be changeable after exit from function
	defer b.usersMutex.Unlock()
	// Adding user
	b.users[userID] = recv
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// No opportunity to change data in list of users
	b.usersMutex.Lock()
	// The list will be changeable after exit from function
	defer b.usersMutex.Unlock()
	// Check that user exists
	if ch, exists := b.users[userID]; exists {
		// Close user's channel
		close(ch)
		// Delete user
		delete(b.users, userID)
	}
}
