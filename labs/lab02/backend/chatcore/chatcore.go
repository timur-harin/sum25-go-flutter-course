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
        case message := <-b.input:
            if message.Broadcast {
                b.usersMutex.RLock()
                chans := make([]chan Message, 0, len(b.users))
                for _, ch := range b.users {
                    chans = append(chans, ch)
                }
                b.usersMutex.RUnlock()

                for _, ch := range chans {
                    select {
                    case ch <- message:
                    default:
                    }
                }
            } else {
                b.usersMutex.RLock()
                ch, ok := b.users[message.Recipient]
                b.usersMutex.RUnlock()
                
                if ok {
                    select {
                    case ch <- message:
                    default:
                    }
                }
            }
        case <-b.ctx.Done():
            return
        }
    }
}
// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
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
	b.users[userID] = recv
	b.usersMutex.Unlock()
	// TODO: Register user and their receiving channel
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// TODO: Remove user from registry
	b.usersMutex.Lock()
	delete(b.users, userID)
	b.usersMutex.Unlock()
}
