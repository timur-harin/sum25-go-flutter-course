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
	tm := new(TaskManager)
	tm.tasks = make(map[int]*Task)
	tm.nextID = 1
	return tm
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	task := new(Task)

	task.ID = tm.nextID
	task.Description = description
	task.Title = title
	if title == "" {
		return nil, ErrEmptyTitle
	}
	task.CreatedAt = time.Now()
	task.Done = false

	tm.nextID++
	tm.tasks[task.ID] = task
	return task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if tm.tasks[id] == nil {
		return ErrTaskNotFound
	}
	if title == "" {
		return ErrEmptyTitle
	}

	task := tm.tasks[id]

	task.Title = title
	task.Description = description
	task.Done = done
	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if tm.tasks[id] == nil {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)

	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if tm.tasks[id] == nil {
		return nil, ErrTaskNotFound
	}
	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var result []*Task

	for _, task := range tm.tasks {
		if (filterDone != nil && *filterDone) || (task.Done) {
			result = append(result, task)
		}
	}
	return result
}
