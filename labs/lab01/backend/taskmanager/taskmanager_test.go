package taskmanager

import (
	"testing"
)

func TestNewTaskManager(t *testing.T) {
	tm := NewTaskManager()
	if tm == nil {
		t.Error("NewTaskManager() returned nil")
	}
	if tm.tasks == nil {
		t.Error("tasks map is nil")
	}
	if tm.nextID != 1 {
		t.Errorf("Expected nextID to be 1, got %d", tm.nextID)
	}
}

func TestAddTask(t *testing.T) {
	tm := NewTaskManager()
	tests := []struct {
		name        string
		title       string
		description string
		expectError bool
	}{
		{
			name:        "valid task",
			title:       "Test Task",
			description: "Test Description",
			expectError: false,
		},
		{
			name:        "empty title",
			title:       "",
			description: "Test Description",
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			task, err := tm.AddTask(tt.title, tt.description)

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != ErrEmptyTitle {
					t.Errorf("Expected ErrEmptyTitle, got %v", err)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
				return
			}

			if task.Title != tt.title {
				t.Errorf("Expected title %s, got %s", tt.title, task.Title)
			}
			if task.Description != tt.description {
				t.Errorf("Expected description %s, got %s", tt.description, task.Description)
			}
			if task.Done {
				t.Error("New task should not be marked as done")
			}
			if task.CreatedAt.IsZero() {
				t.Error("CreatedAt should not be zero")
			}
		})
	}
}

func TestGetTask(t *testing.T) {
	tm := NewTaskManager()
	task, err := tm.AddTask("Test Task", "Description")
	if err != nil {
		t.Fatalf("Failed to add task: %v", err)
	}

	tests := []struct {
		name        string
		id          int
		expectError bool
	}{
		{
			name:        "existing task",
			id:          task.ID,
			expectError: false,
		},
		{
			name:        "non-existent task",
			id:          999,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := tm.GetTask(tt.id)

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != ErrTaskNotFound {
					t.Errorf("Expected ErrTaskNotFound, got %v", err)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
				return
			}

			if got.ID != tt.id {
				t.Errorf("Expected task ID %d, got %d", tt.id, got.ID)
			}
		})
	}
}

func TestUpdateTask(t *testing.T) {
	tm := NewTaskManager()
	task, err := tm.AddTask("Test Task", "Description")
	if err != nil {
		t.Fatalf("Failed to add task: %v", err)
	}

	tests := []struct {
		name        string
		id          int
		title       string
		description string
		done        bool
		expectError bool
	}{
		{
			name:        "valid update",
			id:          task.ID,
			title:       "Updated Task",
			description: "Updated Description",
			done:        true,
			expectError: false,
		},
		{
			name:        "non-existent task",
			id:          999,
			title:       "Updated Task",
			description: "Updated Description",
			done:        true,
			expectError: true,
		},
		{
			name:        "empty title",
			id:          task.ID,
			title:       "",
			description: "Updated Description",
			done:        true,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tm.UpdateTask(tt.id, tt.title, tt.description, tt.done)

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
				return
			}

			// Verify the task was updated correctly
			updatedTask, err := tm.GetTask(tt.id)
			if err != nil {
				t.Errorf("Failed to get updated task: %v", err)
				return
			}

			if updatedTask.Title != tt.title {
				t.Errorf("Expected title %s, got %s", tt.title, updatedTask.Title)
			}
			if updatedTask.Description != tt.description {
				t.Errorf("Expected description %s, got %s", tt.description, updatedTask.Description)
			}
			if updatedTask.Done != tt.done {
				t.Errorf("Expected done %v, got %v", tt.done, updatedTask.Done)
			}
		})
	}
}

func TestDeleteTask(t *testing.T) {
	tm := NewTaskManager()
	task, err := tm.AddTask("Test Task", "Description")
	if err != nil {
		t.Fatalf("Failed to add task: %v", err)
	}

	tests := []struct {
		name        string
		id          int
		expectError bool
	}{
		{
			name:        "existing task",
			id:          task.ID,
			expectError: false,
		},
		{
			name:        "non-existent task",
			id:          999,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tm.DeleteTask(tt.id)

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != ErrTaskNotFound {
					t.Errorf("Expected ErrTaskNotFound, got %v", err)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
				return
			}

			// Verify task was actually deleted
			_, err = tm.GetTask(tt.id)
			if err != ErrTaskNotFound {
				t.Error("Task should have been deleted")
			}
		})
	}
}

func TestListTasks(t *testing.T) {
	tm := NewTaskManager()

	// Add some tasks
	_, _ = tm.AddTask("Task 1", "Description 1")
	task2, _ := tm.AddTask("Task 2", "Description 2")
	_, _ = tm.AddTask("Task 3", "Description 3")

	// Mark one task as done
	tm.UpdateTask(task2.ID, task2.Title, task2.Description, true)

	tests := []struct {
		name     string
		filter   *bool
		expected int
	}{
		{
			name:     "all tasks (no filter)",
			filter:   nil,
			expected: 3,
		},
		{
			name:     "only done tasks",
			filter:   &[]bool{true}[0],
			expected: 1,
		},
		{
			name:     "only pending tasks",
			filter:   &[]bool{false}[0],
			expected: 2,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tasks := tm.ListTasks(tt.filter)
			if len(tasks) != tt.expected {
				t.Errorf("ListTasks() returned %d tasks, want %d", len(tasks), tt.expected)
			}

			// Verify that filtered tasks match the filter criteria
			if tt.filter != nil {
				for _, task := range tasks {
					if task.Done != *tt.filter {
						t.Errorf("Task %d has Done=%v, expected %v", task.ID, task.Done, *tt.filter)
					}
				}
			}
		})
	}
}
