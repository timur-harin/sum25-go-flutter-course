package chatcore

import (
	"context"
	"errors"
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
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	defer close(b.done)

	for {
		select {
		case <-b.ctx.Done():
			return

		case msg := <-b.input:
			b.usersMutex.RLock()
			switch msg.Broadcast {
			case true:
				for _, ch := range b.users {
					ch <- msg
				}
			case false:
				if dest, ok := b.users[msg.Recipient]; ok {
					dest <- msg
				}
			}
			b.usersMutex.RUnlock()
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if b.ctx.Err() != nil {
		return errors.New("broker is closed")
	}

	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return errors.New("broker is closed")
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	b.users[userID] = recv
	b.usersMutex.Unlock()
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	delete(b.users, userID)
	b.usersMutex.Unlock()
}
