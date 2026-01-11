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
	defer close(b.done)

	for {
		select {
		case <-b.ctx.Done():
			return
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, usrCh := range b.users {
					go func(ch chan Message) {
						ch <- msg
					}(usrCh)
				}
			} else {
				usrCh, ok := b.users[msg.Recipient]
				if ok {
					go func(ch chan Message) {
						ch <- msg
					}(usrCh)
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
		return b.ctx.Err()
	case b.input <- msg:
		return nil
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.users[userID] = recv
	// TODO: Register user and their receiving channel
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	delete(b.users, userID)
	// TODO: Remove user from registry
}
