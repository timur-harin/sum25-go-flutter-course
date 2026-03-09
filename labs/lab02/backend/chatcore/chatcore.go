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

func (b *Broker) routeMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast {
		for _, ch := range b.users {
			select {
			case ch <- msg:
			default:
			}
		}
		return
	}

	if ch, ok := b.users[msg.Recipient]; ok {
		select {
		case ch <- msg:
		default:
		}
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	for {
		select {
		case msg := <-b.input:
			b.routeMessage(msg)
		case <-b.ctx.Done():
			close(b.done)
			return
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return b.ctx.Err()
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
