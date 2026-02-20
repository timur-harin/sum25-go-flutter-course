package chatcore

import (
	"context"
	"sync"
)

// Sender, Recipient, Content, Broadcast, Timestamp
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
	defer close(b.done)

	for {
		select {
		case <-b.ctx.Done():
			return
		case msg := <-b.input:
			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, ch := range b.users {
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

// SendMessage sends a message to the broker's input channel
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return context.Canceled
	case <-b.done:
		return context.Canceled
	default:

	}

	select {
	case <-b.ctx.Done():
		return context.Canceled
	case <-b.done:
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
	if ch, ok := b.users[userID]; ok {
		close(ch)
		delete(b.users, userID)
	}
}
