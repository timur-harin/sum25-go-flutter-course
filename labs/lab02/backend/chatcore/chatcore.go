package chatcore

import (
	"context"
	"fmt"
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
	for {
		select {
		case <-b.ctx.Done():
			close(b.done)
			return

		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, ch := range b.users {
					select {
					case ch <- msg:
					default:
						fmt.Println("default")
					}
				}
			} else {
				if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
					default:
						// Optional: drop or log if channel is full
					}
				}
			}
			b.usersMutex.RUnlock()
		}

	}

}

// TODO: Implement event loop (fan-in/fan-out pattern)

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if b.ctx != nil {
		select {
		case <- b.ctx.Done():
			return fmt.Errorf("some context error")
		default:
			
		}
	}

	if msg.Broadcast {
		for id, ch := range b.users {
			select {
			case ch <- msg:
			default:
				return fmt.Errorf("user %s channel full during broadcast", id)
			}
		}
		return nil
	}

	ch, ok := b.users[msg.Recipient]
	if !ok {
		return fmt.Errorf("recipient %s not registered", msg.Recipient)
	}

	select {
	case ch <- msg:
		return nil
	default:
		return fmt.Errorf("recipient %s channel is full or not ready", msg.Recipient)
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// TODO: Register user and their receiving channel
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	b.users[userID] = recv

}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	ch, ok := b.users[userID]
	if ok {
		close(ch)               // close channel to signal termination
		delete(b.users, userID) // actually remove user
	}
	b.usersMutex.Unlock()
}
