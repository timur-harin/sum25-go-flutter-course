package message

import (
	"sync"
	"testing"
)

func TestAddMessageConcurrent(t *testing.T) {
	store := NewMessageStore()
	n := 100
	var wg sync.WaitGroup
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			msg := Message{Sender: "user", Content: "msg", Timestamp: int64(i)}
			if err := store.AddMessage(msg); err != nil {
				t.Errorf("AddMessage failed: %v", err)
			}
		}(i)
	}
	wg.Wait()
	msgs, err := store.GetMessages("")
	if err != nil {
		t.Fatalf("GetMessages failed: %v", err)
	}
	if len(msgs) != n {
		t.Errorf("expected %d messages, got %d", n, len(msgs))
	}
}

func TestGetMessagesByUser(t *testing.T) {
	store := NewMessageStore()
	store.AddMessage(Message{Sender: "alice", Content: "hi"})
	store.AddMessage(Message{Sender: "bob", Content: "hello"})
	store.AddMessage(Message{Sender: "alice", Content: "bye"})
	msgs, err := store.GetMessages("alice")
	if err != nil {
		t.Fatalf("GetMessages failed: %v", err)
	}
	if len(msgs) != 2 {
		t.Errorf("expected 2 messages for alice, got %d", len(msgs))
	}
}
