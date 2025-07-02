package chatcore

import (
	"context"
	"errors"
	"sync"
	"time"
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

// Run starts the broker event loop (fan-in/fan-out)
func (b *Broker) Run() {
	defer close(b.done)
	for {
		select {
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, userCh := range b.users {
					select {
					case userCh <- msg:
					default:
					}
				}
			} else {
				if userCh, ok := b.users[msg.Recipient]; ok {
					select {
					case userCh <- msg:
					default:

					}
				}
			}
			b.usersMutex.RUnlock()

		case <-b.ctx.Done():
			return

		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
	}
	select {
	case <-b.ctx.Done():
		return errors.New("broker is shut down")
	default:
		b.input <- msg
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
	
	if userCh, ok := b.users[userID]; ok {
		delete(b.users, userID)
		close(userCh)
	}
}