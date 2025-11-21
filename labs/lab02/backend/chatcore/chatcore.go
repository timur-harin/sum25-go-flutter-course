package chatcore

import (
	"context"
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
	for {
		select {
		case <-b.ctx.Done():
			// Shutdown: close all user channels and exit
			b.usersMutex.Lock()
			for _, ch := range b.users {
				close(ch)
			}
			b.users = make(map[string]chan Message)
			b.usersMutex.Unlock()
			close(b.done)
			return
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				// Send to all users
				for _, ch := range b.users {
					// Optionally skip sender if desired
					// if userID == msg.Sender { continue }
					select {
					case ch <- msg:
					default:
						// Drop message if user's channel is full
					}
				}
			} else {
				// Send to specific recipient
				if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
					default:
						// Drop message if recipient's channel is full
					}
				}
			}
			b.usersMutex.RUnlock()
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return context.Canceled
	default:
	}
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return context.Canceled
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
	if ch, ok := b.users[userID]; ok {
		delete(b.users, userID)
		close(ch)
	}

}
