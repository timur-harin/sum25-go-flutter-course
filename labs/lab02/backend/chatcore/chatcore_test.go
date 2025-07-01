package chatcore

import (
	"context"
	"sync"
	"testing"
	"time"
)

type testUser struct {
	ID   string
	Recv chan Message
}

func newTestUser(id string) *testUser {
	return &testUser{ID: id, Recv: make(chan Message, 10)}
}

func TestBrokerConcurrentDelivery(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	broker := NewBroker(ctx)
	go broker.Run()

	n := 10
	users := make([]*testUser, n)
	for i := 0; i < n; i++ {
		users[i] = newTestUser(string(rune('A' + i)))
		broker.RegisterUser(users[i].ID, users[i].Recv)
	}

	var wg sync.WaitGroup
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(sender *testUser) {
			defer wg.Done()
			msg := Message{Sender: sender.ID, Content: "hello", Broadcast: true}
			if err := broker.SendMessage(msg); err != nil {
				t.Errorf("SendMessage failed: %v", err)
			}
		}(users[i])
	}
	wg.Wait()

	// Each user should receive n messages
	for _, u := range users {
		received := 0
		deadline := time.After(1 * time.Second)
		for received < n {
			select {
			case <-deadline:
				t.Fatalf("User %s did not receive all messages", u.ID)
			case <-u.Recv:
				received++
			}
		}
	}
}

func TestBrokerBroadcast(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	broker := NewBroker(ctx)
	go broker.Run()

	a := newTestUser("A")
	b := newTestUser("B")
	broker.RegisterUser(a.ID, a.Recv)
	broker.RegisterUser(b.ID, b.Recv)

	msg := Message{Sender: a.ID, Content: "hi all", Broadcast: true}
	if err := broker.SendMessage(msg); err != nil {
		t.Fatalf("SendMessage failed: %v", err)
	}

	select {
	case m := <-a.Recv:
		if m.Content != "hi all" {
			t.Errorf("A got wrong message: %v", m.Content)
		}
	case <-time.After(500 * time.Millisecond):
		t.Error("A did not receive broadcast")
	}
	select {
	case m := <-b.Recv:
		if m.Content != "hi all" {
			t.Errorf("B got wrong message: %v", m.Content)
		}
	case <-time.After(500 * time.Millisecond):
		t.Error("B did not receive broadcast")
	}
}

func TestBrokerPrivateMessage(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	broker := NewBroker(ctx)
	go broker.Run()

	a := newTestUser("A")
	b := newTestUser("B")
	broker.RegisterUser(a.ID, a.Recv)
	broker.RegisterUser(b.ID, b.Recv)

	msg := Message{Sender: a.ID, Recipient: b.ID, Content: "hi B", Broadcast: false}
	if err := broker.SendMessage(msg); err != nil {
		t.Fatalf("SendMessage failed: %v", err)
	}

	select {
	case m := <-b.Recv:
		if m.Content != "hi B" || m.Sender != a.ID {
			t.Errorf("B got wrong message: %+v", m)
		}
	case <-time.After(500 * time.Millisecond):
		t.Error("B did not receive private message")
	}
	select {
	case <-a.Recv:
		t.Error("A should not receive their own private message")
	case <-time.After(200 * time.Millisecond):
		// ok
	}
}

func TestBrokerContextCancellation(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	broker := NewBroker(ctx)
	go broker.Run()
	a := newTestUser("A")
	broker.RegisterUser(a.ID, a.Recv)
	cancel()
	err := broker.SendMessage(Message{Sender: a.ID, Content: "should fail", Broadcast: true})
	if err == nil {
		t.Error("Expected error after context cancel, got nil")
	}
}
