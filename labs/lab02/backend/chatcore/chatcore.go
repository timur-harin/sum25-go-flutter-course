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
	go func() {
		for {
			select {
			case <-b.ctx.Done():
				close(b.done)
				return
			case msg := <-b.input:
				b.usersMutex.RLock()
				if msg.Broadcast {
					for userID, userChan := range b.users {
						if userID != msg.Sender {
							select {
							case userChan <- msg:
							default:
							}
						} else {
							select {
							case userChan <- msg:
							default:
							}
						}
					}
				} else {
					if userChan, exists := b.users[msg.Recipient]; exists {
						select {
						case userChan <- msg:
						default:
						}
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
	case <-b.ctx.Done():
		return b.ctx.Err()
	default:
	}

	select {
	case <-b.ctx.Done():
		return b.ctx.Err()
	case b.input <- msg:
		return nil
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
