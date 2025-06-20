package taskmanager

import (
	"errors"
	"time"
)

var (
	ErrTaskNotFound = errors.New("task not found")
	ErrEmptyTitle   = errors.New("task title cannot be empty")
	ErrInvalidID    = errors.New("invalid task ID")
)

type Task struct {
	ID          int
	Title       string
	Description string
	Done        bool
	CreatedAt   time.Time
}

type TaskManager struct {
	tasks  map[int]*Task
	nextID int
}

func NewTaskManager() *TaskManager {
	return &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1,
	}

}

func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	}

	task := &Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}

	tm.tasks[tm.nextID] = task
	tm.nextID++

	return task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if id <= 0 {
		return ErrInvalidID
	}

	task, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}

	if title == "" {
		return ErrEmptyTitle
	}

	task.Title = title
	task.Description = description
	task.Done = done

	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if id <= 0 {
		return ErrInvalidID
	}

	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}

	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if id <= 0 {
		return nil, ErrInvalidID
	}

	task, exists := tm.tasks[id]
	if !exists {
		return nil, ErrTaskNotFound
	}

	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var result []*Task

	for _, task := range tm.tasks {
		if filterDone == nil || *filterDone == task.Done {
			result = append(result, task)
		}
	}
	return result
}
