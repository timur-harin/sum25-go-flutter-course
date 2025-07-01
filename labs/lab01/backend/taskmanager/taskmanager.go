package taskmanager

import (
	"errors"
	"sort"
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
	manager := TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}
	return &manager
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement this function
	if title == "" {
		return Task{}, ErrEmptyTitle
	}
	t := Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}
	tm.tasks[t.ID] = t
	tm.nextID++
	return t, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	} else if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}
	t := tm.tasks[id]
	t.Title = title
	t.Description = description
	t.Done = done
	tm.tasks[id] = t
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement this function
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	// TODO: Implement this function
	if _, ok := tm.tasks[id]; !ok {
		return Task{}, ErrTaskNotFound
	}
	t := tm.tasks[id]
	return t, nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	// TODO: Implement this function
	var res []Task
	if filterDone == nil {
		for _, t := range tm.tasks {
			res = append(res, t)
		}
		return res
	}
	for _, t := range tm.tasks {
		if t.Done == *filterDone {
			res = append(res, t)
		}
	}

	sort.Slice(res, func(i, j int) bool {
		return res[i].ID < res[j].ID
	})

	return res
}
