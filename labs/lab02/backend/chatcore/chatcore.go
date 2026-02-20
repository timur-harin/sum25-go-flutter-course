package chatcore

import (
	"context"
	"sync"
)

// Message represents a chat message
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
	input      chan Message            // Incoming messages
	users      map[string]chan Message // userID -> receiving channel
	usersMutex sync.RWMutex            // Protects users map
	done       chan struct{}           // For shutdown
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
		for {
			select {
			case msg, ok := <-b.input:
				if !ok {
					b.input = nil
					break
				}
				if msg.Broadcast {
					b.usersMutex.Lock()
					for _, ch := range b.users {
						ch <- msg
					}
					b.usersMutex.Unlock()
				}
				if !msg.Broadcast {
					b.users[msg.Recipient] <- msg
				}
			case <-b.done:
				return
			case <-b.ctx.Done():
				return
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
		b.input <- msg
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
