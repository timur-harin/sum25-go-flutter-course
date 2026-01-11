package chatcore

import (
	"context"
	"errors"
	"sync"
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
	input      chan Message
	users      map[string]chan Message
	usersMutex sync.RWMutex
	done       chan struct{}
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

// Run starts the broker event loop
func (b *Broker) Run() {
	go func() {
		defer close(b.done)
		for {
			select {
			case <-b.ctx.Done():
				return
			case msg := <-b.input:
				b.dispatchMessage(msg)
			}
		}
	}()
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if b.ctx.Err() != nil {
		return errors.New("broker is shutting down")
	}

	select {
	case <-b.ctx.Done():
		return errors.New("broker is shutting down")
	case b.input <- msg:
		return nil
	}
}

// RegisterUser adds a user and their receiving channel
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}

// dispatchMessage delivers the message to appropriate recipients
func (b *Broker) dispatchMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast {
		for _, ch := range b.users {
			select {
			case ch <- msg:
			default:
				// drop message if channel is full
			}
		}
	} else {
		if ch, ok := b.users[msg.Recipient]; ok {
			select {
			case ch <- msg:
			default:
				// drop message if channel is full
			}
		}
	}
}
