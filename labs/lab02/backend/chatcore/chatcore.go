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
		case <-b.ctx.Done():
			return
		case msg := <-b.input:
			// Set timestamp if not already set
			if msg.Timestamp == 0 {
				msg.Timestamp = time.Now().Unix()
			}

			b.usersMutex.RLock()
			if msg.Broadcast {
				// Send to all users including sender
				for _, userChan := range b.users {
					select {
					case userChan <- msg:
					case <-time.After(100 * time.Millisecond):
						// Timeout, skip this user
					}
				}
			} else {
				// Send to specific recipient
				if recipientChan, exists := b.users[msg.Recipient]; exists {
					select {
					case recipientChan <- msg:
					case <-time.After(100 * time.Millisecond):
						// Timeout, skip
					}
				}
			}
			b.usersMutex.RUnlock()
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
	select {
	case <-b.ctx.Done():
		return errors.New("broker context cancelled")
	case b.input <- msg:
		return nil
	case <-time.After(100 * time.Millisecond):
		return errors.New("broker input channel timeout")
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// TODO: Register user and their receiving channel
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// TODO: Remove user from registry
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
