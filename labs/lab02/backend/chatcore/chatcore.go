package chatcore

import (
	"context"
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
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	for {
		select {
		case <-b.ctx.Done():
			close(b.done)
			return

		case msg := <-b.input:

			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, userChan := range b.users {
					select {
					case userChan <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			} else {
				b.usersMutex.RLock()
				if userChan, ok := b.users[msg.Recipient]; ok {
					select {
					case userChan <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			}
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
	select {
	case <-b.ctx.Done():
		return fmt.Errorf("context canceled")
	case b.input <- msg:
		return nil
	default:
		return fmt.Errorf("broker input channel is full")
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
