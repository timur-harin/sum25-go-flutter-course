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
	taskmanager := new(TaskManager)
	taskmanager.nextID = 1
	taskmanager.tasks = make(map[int]Task)
	return taskmanager
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement this function
	if title == "" {
		return Task{}, ErrEmptyTitle
	}

	tm.tasks[tm.nextID] = Task{
		Title:       title,
		Description: description,
		ID:          tm.nextID,
		Done:        false,
		CreatedAt:   time.Now(),
	}

	task := tm.tasks[tm.nextID]
	tm.nextID += 1
	return task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement this function
	_, err := tm.tasks[id]
	if !err {
		return ErrTaskNotFound
	}
	if title == "" {
		return ErrEmptyTitle
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
	// TODO: Implement this function
	_, err := tm.tasks[id]
	if !err {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	// TODO: Implement this function
	_, err := tm.tasks[id]
	if !err {
		return Task{}, ErrTaskNotFound
	}

	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	// TODO: Implement this function
	tasks := []Task{}
	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			tasks = append(tasks, task)
		}
	}
	return tasks
}
