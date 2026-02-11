package chatcore

import (
	"context"
	"errors"
	"fmt"
	"sync"
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
		ctx:        ctx,
		input:      make(chan Message, 100),
		users:      make(map[string]chan Message),
		usersMutex: sync.RWMutex{},
		done:       make(chan struct{}),
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	for {
		select {
		case <-b.done:
			close(b.input)
			close(b.done)
			return

		case msg := <-b.input:
			b.SendMessage(msg)
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
	err := b.ctx.Err()
	if err != nil {
		return fmt.Errorf("operation cancelled: %v", err)
	}

	if msg.Content == "" {
		return errors.New("message content cannot be empty")
	}

	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast == true {
		for _, rcv := range b.users {
			rcv <- msg
		}
	} else {
		_, exists := b.users[msg.Recipient]
		if !exists {
			return errors.New("recipient not found")
		}

		for id, rcv := range b.users {
			if msg.Recipient == id {
				rcv <- msg
			}
		}
	}
	return nil
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
