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
			close(b.done)
			b.usersMutex.Lock()
			for _, ch := range b.users {
				close(ch)
			}
			b.usersMutex.Unlock()
			return
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, ch := range b.users {
					ch <- msg
				}
			} else {
				if ch, ok := b.users[msg.Recipient]; ok {
					ch <- msg
				}
			}
			b.usersMutex.RUnlock()
		}
	}
}

func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker context canceled")
	case <-b.done:
		return errors.New("broker is stopped")
	default:
	}

	select {
	case <-b.ctx.Done():
		return errors.New("broker context canceled")
	case <-b.done:
		return errors.New("broker is stopped")
	case b.input <- msg:
		return nil
	}
}

func (b *Broker) RegisterUser(userID string, recv chan Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker context canceled")
	default:
	}

	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
	return nil
}

func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
