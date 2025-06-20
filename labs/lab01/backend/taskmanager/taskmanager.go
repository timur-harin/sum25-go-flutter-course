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
	var taskManager *TaskManager = &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 0,
	}
	taskManager.nextID++
	return taskManager
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	}
	var task *Task = &Task{tm.nextID, title, description, false, time.Now()}
	tm.tasks[tm.nextID] = task
	return task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if id < 0 {
		return ErrInvalidID
	}
	if title == "" {
		return ErrEmptyTitle
	}
	if task, ok := tm.tasks[id]; ok {
		task.Title = title
		task.Description = description
		task.Done = done

		return nil
	}
	return ErrTaskNotFound
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if id < 0 {
		return ErrInvalidID
	}
	if task, ok := tm.tasks[id]; ok {
		delete(tm.tasks, task.ID)
		return nil
	}
	return ErrTaskNotFound
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if id < 0 {
		return nil, ErrInvalidID
	}
	if task, ok := tm.tasks[id]; ok {
		return task, nil
	}
	return nil, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var doneTasks []*Task = make([]*Task, 0)
	for id, task := range tm.tasks {
		if task.Done == *filterDone {
			doneTasks[id] = task
		}
	}
	return doneTasks
}
