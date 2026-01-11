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
	go func() {
		for {
			select {
			case <-b.ctx.Done():
				close(b.done)
				return
			case msg, ok := <-b.input:
				if !ok {
					close(b.done)
					return
				}
				sendWithTimeout := func(ch chan Message, msg Message) bool {
					select {
					case ch <- msg:
						return true
					case <-time.After(500 * time.Millisecond):
						return false
					case <-b.ctx.Done():
						return false
					}
				}

				b.usersMutex.RLock()
				if msg.Broadcast {
					for _, ch := range b.users {
						sendWithTimeout(ch, msg)
					}
				} else {
					if ch, ok := b.users[msg.Recipient]; ok {
						sendWithTimeout(ch, msg)
					}
				}
				b.usersMutex.RUnlock()
			}
		}
	}()
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case b.input <- msg:
		return nil
	case <-time.After(1 * time.Second):
		return errors.New("timeout")
	case <-b.ctx.Done():
		return errors.New("stopped")
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
