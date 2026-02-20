package chatcore

import (
	"context"
	"sync"
)

// Message represents a chat message
type Message struct {
	Sender    string // user ID of sender
	Recipient string // user ID of recipient; empty if broadcast
	Content   string
	Broadcast bool  // if true, ignore Recipient and send to all users
	Timestamp int64 // Unix nanoseconds
}

// Broker handles message routing between users.
type Broker struct {
	ctx        context.Context
	input      chan Message            // fan‐in channel for new messages
	users      map[string]chan Message // userID → outbound channel
	usersMutex sync.RWMutex            // protects users map
	done       chan struct{}           // closed when broker stops
}

// NewBroker creates a new Broker with its own shutdown channel.
func NewBroker(ctx context.Context) *Broker {
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run starts the broker’s main loop in a goroutine.
func (b *Broker) Run() {
	go func() {
		defer close(b.done)
		for {
			select {
			case <-b.ctx.Done():
				return
			case msg, ok := <-b.input:
				if !ok {
					return
				}
				b.dispatch(msg)
			}
		}
	}()
}

// dispatch fans‐out a message either to all users (broadcast) or to one recipient.
func (b *Broker) dispatch(msg Message) {
	if msg.Broadcast {
		b.usersMutex.RLock()
		defer b.usersMutex.RUnlock()
		for _, ch := range b.users {
			select {
			case ch <- msg:
			case <-b.ctx.Done():
			}
		}
	} else {
		b.usersMutex.RLock()
		ch, ok := b.users[msg.Recipient]
		b.usersMutex.RUnlock()
		if ok {
			select {
			case ch <- msg:
			case <-b.ctx.Done():
			}
		}
	}
}

// SendMessage injects a new message into the broker.
// Returns context.Err() if broker is shut down.
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return b.ctx.Err()
	case b.input <- msg:
		return nil
	}
}

// RegisterUser registers a new user with their own receive channel.
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser removes a user and closes their channel.
func (b *Broker) UnregisterUser(userID string) {
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
