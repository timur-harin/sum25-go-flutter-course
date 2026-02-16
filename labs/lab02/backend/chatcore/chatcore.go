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
	for {
		select {
		case <-b.ctx.Done():
			b.usersMutex.Lock()
			for _, ch := range b.users {
				close(ch)
			}
			b.users = make(map[string]chan Message)
			b.usersMutex.Unlock()
			close(b.done)
			return
		case msg := <-b.input:
			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, ch := range b.users {
					ch <- msg
				}
				b.usersMutex.RUnlock()
			} else if msg.Recipient != "" {
				b.usersMutex.RLock()
				ch, ok := b.users[msg.Recipient]
				b.usersMutex.RUnlock()
				if ok {
					ch <- msg
				}
			}
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker is closed")
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
	if ch, ok := b.users[userID]; ok {
		close(ch)
		delete(b.users, userID)
	}
	b.usersMutex.Unlock()
}
