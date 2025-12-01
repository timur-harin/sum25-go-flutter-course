package chatcore

import (
	"context"
	"errors"
	"sync"
	"sync/atomic"
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

	stopped atomic.Bool
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
	go func() {
		defer close(b.done)

		for {
			select {
			case <-b.ctx.Done():
				b.stopped.Store(true)
				b.usersMutex.Lock()
				for _, ch := range b.users {
					close(ch)
				}
				b.usersMutex.Unlock()
				return

			case msg := <-b.input:
				if msg.Timestamp == 0 {
					msg.Timestamp = time.Now().Unix()
				}
				if msg.Broadcast {
					b.broadcastMessage(msg)
				} else {
					b.sendPrivateMessage(msg)
				}
			}
		}
	}()
}

func (b *Broker) SendMessage(msg Message) error {
	if b.stopped.Load() {
		return errors.New("broker stopped")
	}

	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		b.stopped.Store(true)
		return errors.New("broker stopped")
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
	if ch, ok := b.users[userID]; ok {
		close(ch)
		delete(b.users, userID)
	}
}

func (b *Broker) broadcastMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	for _, ch := range b.users {
		select {
		case ch <- msg:
		default:
		}
	}
}

func (b *Broker) sendPrivateMessage(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if ch, ok := b.users[msg.Recipient]; ok {
		select {
		case ch <- msg:
		default:
		}
	}
}
