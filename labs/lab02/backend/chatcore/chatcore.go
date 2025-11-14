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
	closed     bool                    // закрыт ли брокер
	closedMu   sync.Mutex              // мьютекс для closed
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
			b.closedMu.Lock()
			if !b.closed {
				b.closed = true
				close(b.input)
				close(b.done)
			}
			b.closedMu.Unlock()
			return
		case msg, ok := <-b.input:
			if !ok {
				return
			}
			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, ch := range b.users {
					// Не блокируемся, если канал переполнен
					select {
					case ch <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			} else if msg.Recipient != "" {
				b.usersMutex.RLock()
				if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
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
	b.closedMu.Lock()
	closed := b.closed
	b.closedMu.Unlock()
	if closed {
		return context.Canceled
	}
	select {
	case <-b.ctx.Done():
		return context.Canceled
	case b.input <- msg:
		return nil
	}
}

// RegisterUser adds a user to the broker
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
