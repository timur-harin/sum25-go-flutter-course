package chatcore

import (
	"context"
	"errors"
	"runtime"
	"sync"
	"time"
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
	ID        string
}

// Broker handles message routing between users
// Contains context, input channel, user registry, mutex, done channel

type Broker struct {
	ctx        context.Context
	input      chan Message            // Incoming messages
	users      map[string]chan Message // userID -> receiving channel
	usersMutex sync.RWMutex            // Protects users map
	done       chan struct{}           // For shutdown
	started    bool                    // Indicates if the broker has started
	startMutex sync.Mutex              // Protects started flag
	// TODO: Add more fields if needed
}

// NewBroker creates a new message broker
func NewBroker(ctx context.Context) *Broker {
	// TODO: Initialize broker fields
	return &Broker{
		ctx:        ctx,
		input:      make(chan Message, 100),
		users:      make(map[string]chan Message),
		usersMutex: sync.RWMutex{},
		done:       make(chan struct{}),
		started:    false,
		startMutex: sync.Mutex{},
	}
}

// Run starts the broker event loop (goroutine)
func (b *Broker) Run() {
	// TODO: Implement event loop (fan-in/fan-out pattern)
	b.startMutex.Lock()
	b.started = true
	b.startMutex.Unlock()

	go func() {
		defer close(b.done)
		for {
			select {
			case <-b.ctx.Done():
				return
			case msg := <-b.input:
				if msg.Timestamp == 0 {
					msg.Timestamp = time.Now().Unix()
				}

				b.usersMutex.RLock()
				if msg.Broadcast {
					// Broadcast to all users (including sender)
					for _, userChan := range b.users {
						select {
						case userChan <- msg:
						default:
							// Channel is full, skip this user
						}
					}
				} else {
					// Send to specific recipient
					if userChan, exists := b.users[msg.Recipient]; exists {
						select {
						case userChan <- msg:
						default:
							// Channel is full
						}
					}
				}
				b.usersMutex.RUnlock()
			}
		}
	}()
}

// SendMessage sends a message to the broker
func (b *Broker) SendMessage(msg Message) error {
	// TODO: Send message to appropriate channel/queue
	// Allow the goroutine a chance to process context cancellation
	runtime.Gosched()

	select {
	case <-b.ctx.Done():
		return b.ctx.Err()
	case <-b.done:
		return errors.New("broker is shutting down")
	case b.input <- msg:
		return nil
	default:
		// If we can't send immediately, check if context is done
		select {
		case <-b.ctx.Done():
			return b.ctx.Err()
		case <-b.done:
			return errors.New("broker is shutting down")
		default:
			return errors.New("message queue is full")
		}
	}
}

// RegisterUser adds a user to the broker
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	// TODO: Register user and their receiving channel
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// Wait waits for the broker to be ready
func (b *Broker) Wait() {
	b.startMutex.Lock()
	defer b.startMutex.Unlock()
	// The started flag will be set when Run() is called
}

// UnregisterUser removes a user from the broker
func (b *Broker) UnregisterUser(userID string) {
	// TODO: Remove user from registry
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	if userChan, exists := b.users[userID]; exists {
		close(userChan)
		delete(b.users, userID)
	}
}
