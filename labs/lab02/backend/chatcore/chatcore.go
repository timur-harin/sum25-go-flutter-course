package chatcore

import (
	"context"
	"errors"
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

func run(input chan Message, output chan Message) {
	for message := range input {
		output <- message
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	for {
		select {
		case msg := <-b.input:
			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, userChan := range b.users {
					select {
					case userChan <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			} else {
				b.usersMutex.RLock()
				userChan, ok := b.users[msg.Recipient]
				if ok {
					select {
					case userChan <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			}
		case <-b.ctx.Done():
			close(b.done)
			return
		case <-b.done:
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
	case <-b.done:
		return errors.New("Content canceled")
	case <-b.ctx.Done():
		return errors.New("Content canceled")
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// TODO: Register user and their receiving channel
	b.usersMutex.Lock()
	b.users[userID] = recv
	b.usersMutex.Unlock()
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// TODO: Remove user from registry
	b.usersMutex.Lock()
	delete(b.users, userID)
	b.usersMutex.Unlock()
}
