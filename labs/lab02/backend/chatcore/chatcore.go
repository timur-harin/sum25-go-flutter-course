package chatcore

import (
	"context"
	"errors"
	"sync"
	"time"
)

// Message represents a chat message
// Sender, Recipient, Content, Broadcast, Timestamp
// TODO: Add more fields if needed

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
	// TODO: Add more fields if needed
}

// NewBroker creates a new message broker
func NewBroker(ctx context.Context) *Broker {
	// TODO: Initialize broker fields
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	defer close(b.done)
	for {
		select {
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, userCh := range b.users {
					select {
					case userCh <- msg:
					default: // pass
					}
				}
			} else {
				// Send to a specific recipient
				if userCh, ok := b.users[msg.Recipient]; ok {
					// Non-blocking send to the specific user's channel
					select {
					case userCh <- msg:
					default:
						// If the recipient's channel is full, the message is dropped.
					}
				}
			}
			b.usersMutex.RUnlock()

		case <-b.ctx.Done():
			// If context is cancelled, shut down the broker
			return

		}
	}
}

// SendMessage sends a message to the broker's input channel.
func (b *Broker) SendMessage(msg Message) error {
	// Set the timestamp if it's not already set
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
	}

	// Use a select to either send the message or return an error if the broker is shutting down.
	select {
	case <-b.ctx.Done():
		return errors.New("broker is shut down")
	default:
		b.input <- msg
		return nil
	}
}

// RegisterUser adds a user and their receiving channel to the broker.
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user from the broker and closes their channel.
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	// Check if the user exists before trying to delete and close
	if userCh, ok := b.users[userID]; ok {
		delete(b.users, userID)
		// Close the channel to signal the client-side that no more messages will be sent
		close(userCh)
	}
}
