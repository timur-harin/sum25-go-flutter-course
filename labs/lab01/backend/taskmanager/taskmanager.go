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
	// TODO: Implement task manager initialization
	task := TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1,
	}
	return &task
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition
	if len(title) == 0 {
		return nil, ErrEmptyTitle
	} else {
		tm.tasks[tm.nextID] = &Task{
			ID:          tm.nextID,
			Title:       title,
			Description: description,
			Done:        false,
			CreatedAt:   time.Now(),
		}
		return tm.tasks[tm.nextID], nil
	}
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	} else if len(title) == 0 {
		return ErrEmptyTitle
	} else {
		tm.tasks[id].Title = title
		tm.tasks[id].Description = description
		tm.tasks[id].Done = done
		return nil
	}
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement task deletion
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	} else {
		delete(tm.tasks, id)
		return nil
	}
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	// TODO: Implement task retrieval
	if _, ok := tm.tasks[id]; !ok {
		return nil, ErrTaskNotFound
	} else {
		return tm.tasks[id], nil
	}
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	tasks := make([]*Task, 0)
	// TODO: Implement task listing with optional filter
	for _, task := range tm.tasks {
		if task.Done {
			tasks = append(tasks, task)
		}
	}
	for _, task := range tm.tasks {
		if !task.Done {
			tasks = append(tasks, task)
		}
	}
	return tasks
}
