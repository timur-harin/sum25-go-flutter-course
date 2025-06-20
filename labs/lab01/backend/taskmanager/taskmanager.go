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
	return &TaskManager{
		tasks:  map[int]*Task{},
		nextID: 1, 
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition

	if title == "" {
		return nil, ErrEmptyTitle
	}

	task_id := tm.nextID

	task := Task{
		task_id,
		title,
		description,
		false,
		time.Now(),
	}

	tm.nextID += 1

	tm.tasks[task_id] = &task

	return &task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update

	if title == "" {
		return ErrEmptyTitle
	}

	if _, ok := tm.tasks[id]; !ok {
		return ErrInvalidID
	}
	
	task := tm.tasks[id]

	task.Title = title
	task.Description = description
	task.Done = done

	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	// TODO: Implement task retrieval
	if _, ok := tm.tasks[id]; !ok {
		return nil, ErrTaskNotFound
	}
	task := tm.tasks[id]
	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	// TODO: Implement task listing with optional filter
	var result []*Task

	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			result = append(result, task)
		}
	}

	return result
}
