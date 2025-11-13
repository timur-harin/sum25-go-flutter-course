package chatcore

import (
	"context"
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
	input      chan Message            // Входящие сообщения от клиентов
	users      map[string]chan Message // userID -> личный канал
	usersMutex sync.RWMutex            // Защита users от гонки
	done       chan struct{}           // Сигнал завершения
}

// NewBroker создает новый брокер
func NewBroker(ctx context.Context) *Broker {
	return &Broker{
		ctx:   ctx,
		input: make(chan Message, 100), // буферизованный канал входящих сообщений
		users: make(map[string]chan Message),
		done:  make(chan struct{}),
	}
}

// Run запускает основной цикл обработки сообщений
func (b *Broker) Run() {
	for {
		select {
		case msg := <-b.input:
			if msg.Broadcast {
				// Рассылаем всем пользователям
				b.usersMutex.RLock()
				for _, ch := range b.users {
					select {
					case ch <- msg:
					default:
						// Если канал переполнен — пропускаем (fail-safe)
					}
				}
				b.usersMutex.RUnlock()
			} else {
				// Отправляем только конкретному получателю
				b.usersMutex.RLock()
				if ch, ok := b.users[msg.Recipient]; ok {
					select {
					case ch <- msg:
					default:
						// Канал переполнен — сообщение теряется
					}
				}
				b.usersMutex.RUnlock()
			}

		case <-b.ctx.Done():
			return // Завершение через внешний контекст
		case <-b.done:
			return // Завершение вручную
		}
	}
}

// SendMessage отправляет сообщение в брокер
func (b *Broker) SendMessage(msg Message) error {
	select {
	case b.input <- msg:
		return nil
	case <-b.ctx.Done():
		return context.Canceled
	case <-b.done:
		return context.Canceled
	}
}

// RegisterUser добавляет пользователя в систему
func (b *Broker) RegisterUser(userID string, recv chan Message) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	b.users[userID] = recv
}

// UnregisterUser удаляет пользователя из системы
func (b *Broker) UnregisterUser(userID string) {
	b.usersMutex.Lock()
	defer b.usersMutex.Unlock()
	delete(b.users, userID)
}
