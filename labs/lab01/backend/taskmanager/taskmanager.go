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
	return &TaskManager{tasks: make(map[int]*Task), nextID: 1}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	} else {
		var task *Task = &Task{tm.nextID, title, description, false, time.Now()}
		tm.tasks[tm.nextID] = task
		tm.nextID++
		return task, nil
	}
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if id < 0 {
		return ErrInvalidID
	} else if tm.tasks[id] == nil {
		return ErrTaskNotFound
	} else if title == "" {
		return ErrEmptyTitle
	} else {
		tm.tasks[id].Title = title
		tm.tasks[id].Description = description
		tm.tasks[id].Done = done
		return nil
	}
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if id < 0 {
		return ErrInvalidID
	} else if tm.tasks[id] == nil {
		return ErrTaskNotFound
	} else {
		delete(tm.tasks, id)
		return nil
	}
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if id < 0 {
		return nil, ErrInvalidID
	} else if tm.tasks[id] == nil {
		return nil, ErrTaskNotFound
	} else {
		return tm.tasks[id], nil
	}
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	t := []*Task{}
	if *filterDone == true {
		for _, task := range tm.tasks {
			if task.Done {
				t = append(t, task)
			}
		}
	} else {
		for _, task := range tm.tasks {
			if !task.Done {
				t = append(t, task)
			}
		}
	}
	return t
}
