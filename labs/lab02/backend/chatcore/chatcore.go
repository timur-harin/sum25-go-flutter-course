package chatcore

import (
	"context"
	"errors"
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
		usersMutex: sync.RWMutex{},
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	go func()  {
		for{
			select{
			case <-b.ctx.Done():
				close(b.done)
				return
			case msg := <-b.input:
				if msg.Broadcast{
					b.broadcastMessage(msg)
				}else{
					b.sendToUser(msg.Recipient, msg)
				}
			}
		}
	}()
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if b.ctx.Err() != nil {
		return errors.New("broker is shutting down")
	}
	select{
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return errors.New("broker is shutting down")
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
	if ch, exist := b.users[userID]; exist {
		close(ch)
		delete(b.users, userID)
	}
}

// sendToUser sends a message to a specific user if registered
func (b *Broker) sendToUser(userID string, msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()
	if ch, ok := b.users[userID]; ok {
		ch <- msg
	}
}

// broadcastMessage sends a message to all registered users except the sender
func (b *Broker) broadcastMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()
	for _, ch := range b.users {
		ch <- msg
	}
}