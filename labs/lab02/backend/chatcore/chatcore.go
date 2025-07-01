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
	cancel     context.CancelFunc
}

// NewBroker creates a new message broker
func NewBroker(parentCtx context.Context) *Broker {
	ctx, cancel := context.WithCancel(parentCtx)
	b := &Broker{
		ctx:    ctx,
		cancel: cancel,
		input:  make(chan Message, 100),
		users:  make(map[string]chan Message),
		done:   make(chan struct{}),
	}
	return b
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	defer close(b.done)
	for {
		select {
		case <-b.ctx.Done():
			// context canceled: shutdown broker
			return

		case msg := <-b.input:
			b.dispatch(msg)
		}
	}
}

func (b *Broker) dispatch(msg Message) {
	if msg.Broadcast {
		b.usersMutex.RLock()
		defer b.usersMutex.RUnlock()
		for _, ch := range b.users {
			// non-blocking send
			select {
			case ch <- msg:
			default:
			}
		}
	} else {
		b.usersMutex.RLock()
		ch, ok := b.users[msg.Recipient]
		b.usersMutex.RUnlock()
		if ok {
			// non-blocking send
			select {
			case ch <- msg:
			default:
			}
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if err := b.ctx.Err(); err != nil {
		return errors.New("broker has been stopped")
	}
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return errors.New("broker has been stopped")
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
	// TODO: Remove user from registry
	b.usersMutex.Lock()
	ch, ok := b.users[userID]
	if ok {
		delete(b.users, userID)
	}
	b.usersMutex.Unlock()

	if ok {
		close(ch)
	}
}

// Stop signals the broker to shut down and waits for it to finish.
func (b *Broker) Stop() {
	// Cancel context to stop Run loop
	b.cancel()
	// Wait until done is closed
	<-b.done
}
