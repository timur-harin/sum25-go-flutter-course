package chatcore

import (
	"context"
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
		input: make(chan Message, 128),
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
			{
				b.usersMutex.RLock()

				if msg.Broadcast {
					for _, ch := range b.users {
						ch := ch

						select {
						case ch <- msg:
						default:
						}
					}
				} else if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
					default:
					}
				}
				b.usersMutex.RUnlock()
			}
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	if err := b.ctx.Err(); err != nil {
		return err
	}

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
