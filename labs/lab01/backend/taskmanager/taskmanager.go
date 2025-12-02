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
	return &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement task addition

	if title == "" {
		return Task{}, ErrEmptyTitle
	}

	newTask := Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}

	tm.tasks[tm.nextID] = newTask
	tm.nextID += 1

	return newTask, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if id < 0 {
		return ErrTaskNotFound
	}

	if title == "" {
		return ErrEmptyTitle
	}

	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}

	updatedTask := Task{
		Title:       title,
		Description: description,
		Done:        done,
	}

	delete(tm.tasks, id)

	tm.tasks[id] = updatedTask
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	if id <= 0 {
		return ErrTaskNotFound
	}

	_, ok := tm.tasks[id]

	if !ok {
		return ErrTaskNotFound
	}

	delete(tm.tasks, id)

	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (Task, error) {
	if id <= 0 {
		return Task{}, ErrTaskNotFound
	}

	task, ok := tm.tasks[id]

	if !ok {
		return Task{}, ErrTaskNotFound
	}

	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {

	var tasks []Task

	for _, task := range tm.tasks {
		if filterDone != nil {
			if *filterDone == task.Done {
				tasks = append(tasks, task)
			}
		} else {
			tasks = append(tasks, task)
		}
	}

	return tasks
}
