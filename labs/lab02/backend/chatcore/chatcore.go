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

// Run starts the broker event loop
func (b *Broker) Run() {
	for {
		select {
		case <-b.ctx.Done():
			close(b.done)
			return
		case msg := <-b.input:
			if msg.Broadcast {
				// Отправляем всем пользователям
				b.usersMutex.RLock()
				for userID, ch := range b.users {
					// Если отправитель и получатель совпадают, то тоже отправляем (тесты требуют)
					select {
					case ch <- msg:
					default:
						// Можно логировать переполнение канала, но для простоты игнорируем
					}
				}
				b.usersMutex.RUnlock()
			} else {
				// Приватное сообщение
				b.usersMutex.RLock()
				recvCh, ok := b.users[msg.Recipient]
				b.usersMutex.RUnlock()
				if ok && msg.Recipient != msg.Sender {
					// Отправляем только получателю, не отправляем обратно отправителю
					select {
					case recvCh <- msg:
					default:
						// Игнорируем, если канал забит
					}
				}
			}
		}
	}
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker context canceled")
	case b.input <- msg:
		return nil
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
