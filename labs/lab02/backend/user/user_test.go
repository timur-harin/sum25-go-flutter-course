package user

import (
	"context"
	"testing"
)

func TestUserValidation(t *testing.T) {
	tests := []struct {
		name      string
		user      User
		expectErr bool
	}{
		{"valid", User{Name: "Alice", Email: "alice@example.com", ID: "1"}, false},
		{"empty name", User{Name: "", Email: "alice@example.com", ID: "1"}, true},
		{"invalid email", User{Name: "Alice", Email: "aliceexample.com", ID: "1"}, true},
		{"empty id", User{Name: "Alice", Email: "alice@example.com", ID: ""}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.user.Validate()
			if tt.expectErr && err == nil {
				t.Error("expected error, got nil")
			}
			if !tt.expectErr && err != nil {
				t.Errorf("unexpected error: %v", err)
			}
		})
	}
}

func TestUserAddRemove(t *testing.T) {
	mgr := NewUserManager()
	user := User{Name: "Bob", Email: "bob@example.com", ID: "bob"}
	if err := mgr.AddUser(user); err != nil {
		t.Fatalf("AddUser failed: %v", err)
	}
	if _, err := mgr.GetUser("bob"); err != nil {
		t.Errorf("GetUser failed: %v", err)
	}
	if err := mgr.RemoveUser("bob"); err != nil {
		t.Errorf("RemoveUser failed: %v", err)
	}
	if _, err := mgr.GetUser("bob"); err == nil {
		t.Error("expected error for removed user, got nil")
	}
}

func TestUserContextCancellation(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	mgr := NewUserManagerWithContext(ctx)
	user := User{Name: "Eve", Email: "eve@example.com", ID: "eve"}
	cancel()
	err := mgr.AddUser(user)
	if err == nil {
		t.Error("expected error after context cancel, got nil")
	}
}
