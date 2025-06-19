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
		tasks: make(map[int]*Task),
		nextID: 1,
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition
	if title ==""{
		return nil, ErrEmptyTitle
	}

	tm.tasks[tm.nextID] = &Task{
		ID: tm.nextID,
		Title: title,
		Description: description,
		Done: false,
		CreatedAt: time.Now(),
	}
	tm.nextID++
	return tm.tasks[tm.nextID-1], nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	if _, err := tm.tasks[id]; !err{
		return ErrTaskNotFound;
	}
	if (title =="") {
		return ErrEmptyTitle
	}
	tm.tasks[id].Title = title
	tm.tasks[id].Description = description
	tm.tasks[id].Done = done
	return nil
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	if _, exist := tm.tasks[id]; !exist {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	
	task, err := tm.tasks[id];if !err {
		return nil, ErrTaskNotFound
	}
	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	slice :=make([]*Task,0)
	for i:=0;i<tm.nextID;i++ {
		if tm.tasks[i].Done==*filterDone{
			slice = append(slice, tm.tasks[i])
		}
	}
	return slice
}
