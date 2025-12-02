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
	// TODO: Implement event loop (fan-in/fan-out pattern)

	defer close(b.done)

    for {
        // Если контекст отменён — чистим и выходим
        if err := b.ctx.Err(); err != nil {
            b.usersMutex.Lock()
            // defer здесь сработает при выходе из Run, разблокировав mutex
            defer b.usersMutex.Unlock()

            for id, ch := range b.users {
                close(ch)
                delete(b.users, id)
            }
            return
        }

        // Ждём новое сообщение (блокирующий receive)
        msg := <-b.input

        b.usersMutex.Lock()
        // Broadcast — рассылаем всем
        if msg.Broadcast {
            for _, ch := range b.users {
                // blocking send; если канал заполнен, рутина заблокируется
                ch <- msg
            }
        } else {
            // адресная пересылка
            if recvCh, ok := b.users[msg.Recipient]; ok {
                recvCh <- msg
            }
        }
        b.usersMutex.Unlock()
    }

}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
	if err := b.ctx.Err(); err != nil {
        return err
    }
    b.input <- msg
    return nil
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// TODO: Register user and their receiving 
	b.usersMutex.Lock()
    defer b.usersMutex.Unlock()
    b.users[userID] = recv
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// TODO: Remove user from registry
	b.usersMutex.Lock()
    defer b.usersMutex.Unlock()
    if ch, ok := b.users[userID]; ok {
        close(ch)
        delete(b.users, userID)
    }
}
