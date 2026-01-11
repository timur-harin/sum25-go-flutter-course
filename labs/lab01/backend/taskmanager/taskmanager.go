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
	return &TaskManager{tasks: make(map[int]Task), nextID: 1}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// Title of a task cannot be empty
	if len(title) == 0 {
		return Task{}, ErrEmptyTitle
	}

	// Creating and adding new task
	// Not done by default
	task := Task{Title: title, Description: description, ID: tm.nextID,
		Done: false, CreatedAt: time.Now()}
	tm.tasks[tm.nextID] = task
	tm.nextID++

	return task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// Title of a task cannot be empty
	if len(title) == 0 {
		return ErrEmptyTitle
	}

	// No task with a specified ID was found
	task, found := tm.tasks[id]
	if !found {
		return ErrTaskNotFound
	}

	// Update the task
	task.Title = title
	task.Description = description
	task.Done = done
	tm.tasks[id] = task

	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	// No task with a specified ID was found
	_, found := tm.tasks[id]
	if !found {
		return ErrTaskNotFound
	}

	// Remove the task
	delete(tm.tasks, id)

	return nil // no error
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (Task, error) {
	// No task with a specified ID was found
	task, found := tm.tasks[id]
	if !found {
		return task, ErrTaskNotFound
	}

	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	res := make([]Task, 0, tm.nextID-1)
	for _, task := range tm.tasks {
		if (filterDone == nil) || (task.Done == *filterDone) {
			res = append(res, task)
		}
	}

	return res
}
