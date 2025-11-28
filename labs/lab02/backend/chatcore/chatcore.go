package chatcore

import (
	"context"
	"fmt"
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
	cancelCtx  context.CancelFunc
	input      chan Message
	users      map[string]chan Message
	usersMutex sync.RWMutex
	done       chan struct{}
	wg         sync.WaitGroup
}

func NewBroker(parentCtx context.Context) *Broker {
	ctx, cancel := context.WithCancel(parentCtx)
	return &Broker{
		ctx:       ctx,
		cancelCtx: cancel,
		input:     make(chan Message, 100),
		users:     make(map[string]chan Message),
		done:      make(chan struct{}),
	}
}

func (b *Broker) Run() {
	b.wg.Add(1)
	go func() {
		defer b.wg.Done()
		defer close(b.done)
		fmt.Println("Broker: Starting event loop...")

		for {
			select {
			case msg := <-b.input:
				b.usersMutex.RLock()

				if msg.Broadcast {
					for userID, userChan := range b.users {
						select {
						case userChan <- msg:
						case <-time.After(100 * time.Millisecond):
							fmt.Printf("Broker: Warning: User %s's channel is blocked, dropping broadcast message.\n", userID)
						case <-b.ctx.Done():
							b.usersMutex.RUnlock()
							fmt.Println("Broker: Context cancelled during broadcast, shutting down.")
							return
						}
					}
				} else {
					if userChan, ok := b.users[msg.Recipient]; ok {
						select {
						case userChan <- msg:
						case <-time.After(100 * time.Millisecond):
							fmt.Printf("Broker: Warning: Recipient %s's channel is blocked, dropping direct message.\n", msg.Recipient)
						case <-b.ctx.Done():
							b.usersMutex.RUnlock()
							fmt.Println("Broker: Context cancelled during direct message, shutting down.")
							return
						}
					} else {
						fmt.Printf("Broker: Recipient %s not found for direct message.\n", msg.Recipient)
					}
				}
				b.usersMutex.RUnlock()

			case <-b.ctx.Done():
				fmt.Println("Broker: Context cancelled, shutting down event loop.")
				return
			}
		}
	}()
}

func (b *Broker) Shutdown() {
	fmt.Println("Broker: Initiating shutdown...")
	b.cancelCtx()
	b.wg.Wait()
	close(b.input)
	fmt.Println("Broker: Shutdown complete.")
}

func (b *Broker) SendMessage(msg Message) error {
	select {
	case b.input <- msg:
		return nil
	case <-b.done:
		return fmt.Errorf("broker is shut down, cannot send message: %v", b.ctx.Err())
	case <-b.ctx.Done():
		return fmt.Errorf("broker context cancelled, cannot send message: %v", b.ctx.Err())
	case <-time.After(500 * time.Millisecond):
		return fmt.Errorf("failed to send message to broker input channel: timeout")
	}
}

func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	if _, exists := b.users[userID]; exists {
		fmt.Printf("Broker: User %s already registered.\n", userID)
		return
	}

	b.users[userID] = recv
	fmt.Printf("Broker: User %s registered.\n", userID)
}

func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()

	if userChan, ok := b.users[userID]; ok {
		delete(b.users, userID)
		close(userChan)
		fmt.Printf("Broker: User %s unregistered and channel closed.\n", userID)
	} else {
		fmt.Printf("Broker: User %s not found for unregistration.\n", userID)
	}
}
