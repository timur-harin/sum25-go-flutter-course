package chatcore

import (
	"context"
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
		case msg := <-b.input:
			b.usersMutex.RLock()
			if msg.Broadcast {
				for _, ch := range b.users {
					// Гарантированная доставка, либо в горутину
					go func(c chan Message) {
						c <- msg
					}(ch)
				}
			} else {
				ch, ok := b.users[msg.Recipient]
				if ok {
					go func(c chan Message) {
						c <- msg
					}(ch)
				}
			}
			b.usersMutex.RUnlock()
		case <-b.ctx.Done():
			close(b.done)
			return
		}
	}
}

func (b *Broker) SendMessage(msg Message) error {
	select {
	case <-b.done:
		return context.Canceled
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return b.ctx.Err()
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
