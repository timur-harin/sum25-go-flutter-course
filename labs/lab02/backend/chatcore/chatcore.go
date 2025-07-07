package chatcore

import (
	"context"
	"errors"
	"sync"
)

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
	input      chan Message            // Incoming messages (fan-in)
	users      map[string]chan Message // userID -> receiving channel (fan-out)
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

// Run starts the broker event loop (fan-in/fan-out pattern)
func (b *Broker) Run() {
	for {
		select {
		case <-b.ctx.Done():
			// Shutdown broker
			close(b.done)
			return
		case msg := <-b.input:
			b.dispatch(msg)
		}
	}
}

// dispatch sends a message to intended recipients
func (b *Broker) dispatch(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast {
		// Send to all users except sender (optional, but usually sender also receives broadcast)
		for _, ch := range b.users {
			// You can decide if sender also receives their own broadcast; here we send to all
			select {
			case ch <- msg:
			default:
				// Optional: drop or log if user channel full to avoid blocking broker
			}
		}
	} else {
		// Private message to specific recipient only
		if ch, ok := b.users[msg.Recipient]; ok {
			select {
			case ch <- msg:
			default:
				// Optional: drop or log if full
			}
		}
	}
}

// SendMessage sends a message to the broker input channel
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker closed or context cancelled")
	case b.input <- msg:
		return nil
	}
}

// RegisterUser adds a user and their receive channel
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
