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
	return &TaskManager{
		tasks:  map[int]*Task{},
		nextID: 1,
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	}

	newTask := &Task{
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

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}

	if title == "" {
		return ErrEmptyTitle
	}

	var toUpdate *Task = tm.tasks[id]

	toUpdate.Title = title
	toUpdate.Description = description
	toUpdate.Done = done

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
	if task, ok := tm.tasks[id]; ok {
		return task, nil
	} else {
		return nil, ErrTaskNotFound
	}
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	if filterDone == nil {
		return nil
	}

	filteredTasks := []*Task{}

	for _, task := range tm.tasks {
		if *filterDone == task.Done {
			filteredTasks = append(filteredTasks, task)
		}
	}

	return filteredTasks
}
