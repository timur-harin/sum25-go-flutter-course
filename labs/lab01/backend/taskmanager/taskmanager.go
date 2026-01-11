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
	taskManager := &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}
	return taskManager
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement task addition
	if title == "" {
		return Task{}, ErrEmptyTitle
	}
	tm.tasks[tm.nextID] = Task{tm.nextID, title, description, false, time.Now()}
	tm.nextID++
	return tm.tasks[tm.nextID-1], nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	}
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}
	tm.tasks[id] = Task{id, title, description, done, time.Now()}
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement task deletion
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	if task, exists := tm.tasks[id]; exists {
		return task, nil
	}
	return Task{}, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	// TODO: Implement task listing with optional filter
	tasks := []Task{}
	for _, task := range tm.tasks {
		if filterDone != nil && *filterDone == true && task.Done {
			tasks = append(tasks, task)
		}
		if filterDone != nil && *filterDone == false && !task.Done {
			tasks = append(tasks, task)
		}
		if filterDone == nil {
			tasks = append(tasks, task)
		}
	}
	return tasks
}
