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

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	go func() {
		defer close(b.done)
		for {
			select {
			case <-b.ctx.Done():
				close(b.input)
				return
			case msg, ok := <-b.input:
				if !ok {
					return
				}
				b.dispatch(msg)
			}
		}
	}()
}

// dispatch routes a message to the appropriate users
func (b *Broker) dispatch(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast {
		// Broadcast to all users including sender
		for _, ch := range b.users {
			select {
			case ch <- msg:
			default:
				// Drop message if channel is full (or handle differently)
			}
		}
	} else {
		// Private message
		if ch, ok := b.users[msg.Recipient]; ok {
			select {
			case ch <- msg:
			default:
				// Drop if full
			}
		}
	}
}

// SendMessage sends a message to the broker input channel
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker is stopped")
	default:
	}

	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return errors.New("broker is stopped")
	}
}

// RegisterUser registers a user and their receiving channel
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser unregisters a user
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
