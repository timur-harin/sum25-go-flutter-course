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
	return &TaskManager{tasks: make(map[int]*Task), nextID: 1}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// Title of a task cannot be empty
	if len(title) == 0 {
		return nil, ErrEmptyTitle
	}

	// Creating and adding new task
	// Not done by default
	taskPtr := &Task{Title: title, Description: description, ID: tm.nextID,
		Done: false, CreatedAt: time.Now()}
	tm.tasks[tm.nextID] = taskPtr
	tm.nextID++

	return taskPtr, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// Title of a task cannot be empty
	if len(title) == 0 {
		return ErrEmptyTitle
	}

	// ID must be positive
	if id <= 0 {
		return ErrInvalidID
	}

	// No task with a specified ID was recorder
	if tm.tasks[id] == nil {
		return ErrTaskNotFound
	}

	// Update the task
	task := tm.tasks[id]
	task.Title = title
	task.Description = description
	task.Done = done

	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	// ID must be positive
	if id <= 0 {
		return ErrInvalidID
	}

	// No task with a specified ID was recorder
	if tm.tasks[id] == nil {
		return ErrTaskNotFound
	}

	// Remove the task
	tm.tasks[id] = nil

	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	// ID must be positive
	if id <= 0 {
		return nil, ErrInvalidID
	}

	// No task with a specified ID was recorder
	if tm.tasks[id] == nil {
		return nil, ErrTaskNotFound
	}

	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	// TODO: Implement task listing with optional filter
	res := make([]*Task, 0, tm.nextID-1)
	for id := range tm.tasks {
		taskPtr := tm.tasks[id]
		if (filterDone == nil) || (taskPtr.Done == *filterDone) {
			res = append(res, taskPtr)
		}
	}

	return res
}
