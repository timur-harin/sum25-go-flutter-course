package chatcore

import (
	"context"
	"errors"
	"sync"
)

var (
	ErrBrokerOffline = errors.New("broker is offline")
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
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

func (b *Broker) Run() {
	for {
		select {
		case <-b.ctx.Done():
			close(b.done)
			return
		case <-b.done:
			return
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast { // broadcast
				for _, ch := range b.users {
					select {
					case ch <- msg:
					default:
					}
				}
			} else { // private message
				if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
					default:
					}
				}
			}
			b.usersMutex.RUnlock()
		}
	}
}

func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return ErrBrokerOffline
	case <-b.done :
		return ErrBrokerOffline
	case b.input <- msg:
		return nil
	}
}

func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
