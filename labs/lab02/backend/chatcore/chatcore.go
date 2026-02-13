package chatcore

import (
	"context"
	"errors"
	"sync"
)

// Message represents a chat message
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
	input      chan Message
	users      map[string]chan Message
	usersMutex sync.RWMutex
	done       chan struct{}
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

// Run starts the broker's message processing loop
func (b *Broker) Run() {
	defer close(b.done)

	for {
		select {
		case <-b.ctx.Done():
			return
		case msg := <-b.input:
			b.routeMessage(msg)
		}
	}
}

func (b *Broker) routeMessage(msg Message) {
    b.usersMutex.RLock()
    defer b.usersMutex.RUnlock()

    if msg.Broadcast {
        // Отправляем всем пользователям, включая отправителя
        for _, ch := range b.users {
            select {
            case ch <- msg:
            default: // Пропускаем если канал полон
            }
        }
    } else {
        // Приватные сообщения
        if ch, ok := b.users[msg.Recipient]; ok {
            select {
            case ch <- msg:
            default: // Пропускаем если канал полон
            }
        }
    }
}

// SendMessage sends a message through the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker is shutting down")
	default:
	}

	// Validate sender exists
	b.usersMutex.RLock()
	_, senderExists := b.users[msg.Sender]
	b.usersMutex.RUnlock()

	if !senderExists {
		return errors.New("sender not registered")
	}

	// Validate recipient for private messages
	if !msg.Broadcast {
		b.usersMutex.RLock()
		_, recipientExists := b.users[msg.Recipient]
		b.usersMutex.RUnlock()

		if !recipientExists {
			return errors.New("recipient not registered")
		}
	}

	select {
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
	delete(b.users, userID)
}