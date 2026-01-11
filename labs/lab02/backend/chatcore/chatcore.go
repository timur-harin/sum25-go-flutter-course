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
	go func() {
		for {
			select {
			case <-b.ctx.Done():
				return
			case <-b.done:
				return
			case msg := <-b.input:
				if msg.Timestamp == 0 {
					msg.Timestamp = time.Now().Unix()
				}
				if msg.Broadcast {
					b.broadcastMessage(msg)
				} else {
					b.sendMessageToUser(msg)
				}
			}
		}
	}()
}

func (b *Broker) SendMessage(msg Message) error {
	if b.ctx.Err() != nil {
		return errors.New("broker is shutting down")
	}
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return errors.New("broker is shutting down")
	case <-b.done:
		return errors.New("broker has been closed")
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

func (b *Broker) sendMessageToUser(msg Message) {
	b.usersMutex.RLock()
	defer b.usersMutex.RUnlock()

	if ch, ok := b.users[msg.Recipient]; ok {
		select {
		case ch <- msg:
		default:
		}
	}
}
