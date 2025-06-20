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
	// TODO: Implement task manager initialization
	return &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1, // Начинаем с ID = 1
	}
	return nil
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition
	var id int = tm.nextID
	curTime := time.Now()
	var task Task = Task{id, title, description, false, curTime}
	tm.tasks[id] = &task
	id++
	tm.nextID = id
	if title == "" {
		return &task, ErrEmptyTitle
	}
	return &task, nil
}

// UpdateTask updates an existing task
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	if _, ok := tm.tasks[id]; ok {
		tm.tasks[id] = &Task{id, title, description, done, tm.tasks[id].CreatedAt}
		if title == "" {
			return ErrEmptyTitle
		}
		return nil
	}
	return ErrInvalidID
}

// DeleteTask removes a task from the manager
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement task deletion
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	// TODO: Implement task retrieval
	if _, ok := tm.tasks[id]; !ok {
		curTime := time.Now()
		var task Task = Task{0, "", "", false, curTime}
		return &task, ErrTaskNotFound
	}
	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	// TODO: Implement task listing with optional filter
	var arr []*Task
	if filterDone != nil {
		for _, task := range tm.tasks {
			arr = append(arr, task)
		}
	} else {
		if *filterDone == true {
			for _, task := range tm.tasks {
				if task.Done == true {
					arr = append(arr, task)
				}
			}
		} else {
			for _, task := range tm.tasks {
				if task.Done == false {
					arr = append(arr, task)
				}
			}
		}
	}
	return arr
}
