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

type Broker struct {
	ctx        context.Context
	input      chan Message
	users      map[string]chan Message
	usersMutex sync.RWMutex
	done       chan struct{}
}

func NewBroker(ctx context.Context) *Broker {
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100),
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

func (b *Broker) Run() {
	for {
		select {
		case <-b.ctx.Done():
			b.usersMutex.Lock()
			for userID, ch := range b.users {
				close(ch)
				delete(b.users, userID)
			}
			b.usersMutex.Unlock()
			close(b.done)
			return

		case msg := <-b.input:
			if msg.Broadcast {
				b.usersMutex.RLock()
				for _, ch := range b.users {
					select {
					case ch <- msg:

					default:

					}
				}
				b.usersMutex.RUnlock()
			} else {
				b.usersMutex.RLock()
				if ch, ok := b.users[msg.Recipient]; ok {
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

func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.done:
		return errors.New("broker has shut down")
	case <-b.ctx.Done():
		return errors.New("context canceled, broker shutting down")
	case b.input <- msg:
		return nil
	}
}

func (b *Broker) RegisterUser(userID string, recvCh chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recvCh
}

func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	if ch, ok := b.users[userID]; ok {
		close(ch)
		delete(b.users, userID)
	}
}
