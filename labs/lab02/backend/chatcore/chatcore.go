package chatcore

import (
	"context"
	"errors"
	"sync"
	"time"
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
		defer close(b.done)
		
		for {
			select {
			case <-b.ctx.Done():
				return
			case msg := <-b.input:
				if msg.Timestamp == 0 {
					msg.Timestamp = time.Now().Unix()
				}
				if msg.Broadcast {
					b.broadcastMessage(msg)
				} else {
					b.sendPrivateMessage(msg)
				}
			}
		}
	}()
}

// broadcastMessage sends message to all registered users
func (b *Broker) broadcastMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()
	
	for _, userChan := range b.users {
		select {
		case userChan <- msg:
		default:
		}
	}
}

// sendPrivateMessage sends message to specific recipient
func (b *Broker) sendPrivateMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()
	
	if recipientChan, exists := b.users[msg.Recipient]; exists {
		select {
		case recipientChan <- msg:
		default:
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return b.ctx.Err()
	default:
	}
	
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return b.ctx.Err()
	default:
		return errors.New("broker input channel is full")
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
	
	if userChan, exists := b.users[userID]; exists {
		close(userChan)
		delete(b.users, userID)
	}
}
