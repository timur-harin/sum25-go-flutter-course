package chatcore

import (
	"context"
	"errors"
	"sync"
	"time"
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
	defer close(b.done)

	for {
		select {
		case <-b.ctx.Done():
			return
		case msg, ok := <-b.input:
			if !ok {
				return
			}
			b.routeMessage(msg)
		}
	}
}

func (b *Broker) routeMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if msg.Broadcast {
		for _, ch := range b.users {
			select {
			case ch <- msg:
			case <-time.After(100 * time.Millisecond):
				continue
			}
		}
	} else if msg.Recipient != "" {
		if ch, ok := b.users[msg.Recipient]; ok {
			select {
			case ch <- msg:
			case <-time.After(100 * time.Millisecond):
				return
			}
		}
	}
}

func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.ctx.Done():
		return errors.New("broker is shutting down")
	case b.input <- msg:
		return nil
	case <-time.After(100 * time.Millisecond):
		return errors.New("broker input queue full")
	}
}

func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
