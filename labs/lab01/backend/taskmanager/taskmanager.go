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
	taskManager := &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1,
	}
	return taskManager
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition
	if title == "" {
		return nil, ErrEmptyTitle
	}
	tm.tasks[tm.nextID] = &Task{tm.nextID, title, description, false, time.Now()}
	tm.nextID++
	return tm.tasks[tm.nextID-1], nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	}
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}
	tm.tasks[id] = &Task{id, title, description, done, time.Now()}
	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement task deletion
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if task, exists := tm.tasks[id]; exists {
		return task, nil
	}
	return nil, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	// TODO: Implement task listing with optional filter
	tasks := []*Task{}
	for _, task := range tm.tasks {
		if filterDone != nil && *filterDone == true && task.Done {
			tasks = append(tasks, task)
		}
		if filterDone != nil && *filterDone == false && !task.Done {
			tasks = append(tasks, task)
		}
	}
	return nil
}
