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

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	if len(title) == 0 {
		return Task{}, ErrEmptyTitle
	}

	taska := Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		CreatedAt:   time.Now(),
	}

	tm.tasks[tm.nextID] = taska
	tm.nextID++

	return taska, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {

	if len(title) == 0 {
		return ErrEmptyTitle
	}

	task, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}

	task.Title = title
	task.Description = description
	task.Done = done

	tm.tasks[id] = task

	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
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

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {

	foundId := -1

	for _, task := range tm.tasks {
		if task.ID == id {
			foundId = task.ID
		}
	}

	if foundId == -1 {
		return Task{}, ErrTaskNotFound
	}

	return tm.tasks[foundId], nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	var taski []Task

	for _, taska := range tm.tasks {
		if filterDone == nil {
			taski = append(taski, taska)
		} else {
			if taska.Done == *filterDone {
				taski = append(taski, taska)
			}
		}
	}

	return taski
}
