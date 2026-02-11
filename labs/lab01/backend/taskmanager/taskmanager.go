package taskmanager

import (
	"errors"
	"time"
)

// Predefined errors
var (
	ErrTaskNotFound = errors.New("task not found")
	ErrEmptyTitle   = errors.New("title cannot be empty")
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
	tasks  map[int]Task
	nextID int
}

// NewTaskManager creates a new task manager
func NewTaskManager() *TaskManager {
	// TODO: Implement task manager initialization
	return &TaskManager{
		tasks:  map[int]Task{},
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

	tm.tasks[task_id] = task

	return &task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	if title == "" {
		return ErrEmptyTitle
	}

	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}

	task := tm.tasks[id]

	task.Title = title
	task.Description = description
	task.Done = done

	tm.tasks[id] = task

	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
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
	return &task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	// TODO: Implement task listing with optional filter
	var result []*Task

	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			result = append(result, &task)
		}
	}

	return result
}
