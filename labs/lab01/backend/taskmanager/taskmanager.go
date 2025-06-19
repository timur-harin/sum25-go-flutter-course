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
		nextID: 1,
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if len(title) == 0 {
		return nil, ErrEmptyTitle
	}

	taska := &Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		CreatedAt:   time.Now(),
	}

	tm.tasks[tm.nextID] = taska
	tm.nextID++

	return taska, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {

	if id < 0 {
		return ErrInvalidID
	}

	if len(title) == 0 {
		return ErrEmptyTitle
	}

	found := false

	for _, task := range tm.tasks {
		if task.ID == id {
			task.Title = title
			task.Description = description
			task.Done = done

			found = true
		}
	}

	if !found {
		return ErrTaskNotFound
	}

	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if id < 0 {
		return ErrInvalidID
	}

	foundId := -1

	for id, task := range tm.tasks {
		if task.ID == id {
			foundId = task.ID
		}
	}

	if foundId == -1 {
		return ErrTaskNotFound
	} else {
		delete(tm.tasks, foundId)
	}

	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if id < 0 {
		return nil, ErrInvalidID
	}

	foundId := -1

	for _, task := range tm.tasks {
		if task.ID == id {
			foundId = task.ID
		}
	}

	if foundId == -1 {
		return nil, ErrTaskNotFound
	}

	return tm.tasks[foundId], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {

	var taski []*Task

	for _, taska := range tm.tasks {
		if taska.Done == *filterDone {
			taski = append(taski, taska)
		}
	}

	return taski
}
