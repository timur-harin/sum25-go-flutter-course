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
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	}
	task := Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}
	tm.tasks[tm.nextID] = task
	tm.nextID++
	return &task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	}
	if task, ok := tm.tasks[id]; ok {
		task.Title = title
		task.Description = description
		task.Done = done
		tm.tasks[id] = task
		return nil
	}
	return ErrTaskNotFound
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	if _, ok := tm.tasks[id]; ok {
		delete(tm.tasks, id)
		return nil
	}
	return ErrTaskNotFound
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if task, ok := tm.tasks[id]; ok {
		return &task, nil
	}
	return nil, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var list []*Task
	for _, t := range tm.tasks {
		if filterDone != nil && t.Done != *filterDone {
			continue
		}
		// создаём копию, чтобы каждый указатель был на свой объект
		taskCopy := t
		list = append(list, &taskCopy)
	}
	return list
}
