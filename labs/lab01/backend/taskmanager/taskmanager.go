package taskmanager

import (
	"errors"
	"time"
)

var (
	// ErrTaskNotFound is returned when a task is not found
	ErrTaskNotFound = errors.New("task not found")
	// ErrEmptyTitle is returned when the task title is empty
	ErrEmptyTitle = errors.New("task title cannot be empty")
	// ErrInvalidID is returned when the task ID is invalid
	ErrInvalidID = errors.New("invalid task ID")
)

// Task represents a single task
type Task struct {
	ID          int
	Title       string
	Description string
	Done        bool
	CreatedAt   time.Time
}

// TaskManager manages a collection of tasks
type TaskManager struct {
	tasks  map[int]*Task
	nextID int
}

// NewTaskManager creates a new task manager
func NewTaskManager() *TaskManager {
	return &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1, // Start IDs from 1
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// Validate title is not empty
	if title == "" {
		return nil, ErrEmptyTitle
	}

	// Create new task with auto-incremented ID
	task := &Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}

	// Store the task and increment ID counter
	tm.tasks[tm.nextID] = task
	tm.nextID++

	return task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// Validate ID is positive
	if id <= 0 {
		return ErrInvalidID
	}

	// Check if task exists
	task, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}

	// Validate new title is not empty
	if title == "" {
		return ErrEmptyTitle
	}

	// Update task fields
	task.Title = title
	task.Description = description
	task.Done = done

	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	// Validate ID is positive
	if id <= 0 {
		return ErrInvalidID
	}

	// Check if task exists before deletion
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}

	// Remove task from map
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	// Validate ID is positive
	if id <= 0 {
		return nil, ErrInvalidID
	}

	// Retrieve task if exists
	task, exists := tm.tasks[id]
	if !exists {
		return nil, ErrTaskNotFound
	}

	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var result []*Task

	// Iterate through all tasks
	for _, task := range tm.tasks {
		// Apply filter if provided
		if filterDone == nil || *filterDone == task.Done {
			result = append(result, task)
		}
	}

	return result
}