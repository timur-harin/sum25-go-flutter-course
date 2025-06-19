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
	if title == "" {
		return nil, ErrEmptyTitle
	}
	nextId := tm.nextID
	task := Task{
		ID:          nextId,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}
	tm.tasks[task.ID] = &task
	tm.nextID++
	return &task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	taskToUpd := tm.tasks[id]
	if taskToUpd == nil {
		return ErrTaskNotFound
	}
	if taskToUpd.ID < 1 {
		return ErrInvalidID
	}
	if title == "" {
		return ErrEmptyTitle
	}
	taskToUpd.Title = title
	taskToUpd.Description = description
	taskToUpd.Done = done
	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if id < 1 {
		return ErrInvalidID
	}
	if tm.tasks[id] == nil {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if id < 1 {
		return nil, ErrInvalidID
	}
	if tm.tasks[id] == nil {
		return nil, ErrTaskNotFound
	}
	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var tasks []*Task
	for _, t := range tm.tasks {
		if filterDone == nil || t.Done == *filterDone {
			tasks = append(tasks, t)
		}
	}
	return tasks
}
