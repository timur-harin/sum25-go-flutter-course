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
	return &TaskManager{tasks: make(map[int]Task), nextID: 1}
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	if title == "" {
		return Task{}, ErrEmptyTitle
	} else {
		task := Task{ID: tm.nextID, Title: title, Description: description, Done: false, CreatedAt: time.Now()}
		tm.tasks[task.ID] = task
		tm.nextID++
		return task, nil
	}
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {

	if title == "" {
		return ErrEmptyTitle
	} else {
		_, err := tm.tasks[id]
		if !err {
			return ErrTaskNotFound
		} else {
			tm.tasks[id] = Task{ID: id, Title: title, Description: description, Done: done, CreatedAt: time.Now()}
			return nil
		}
	}
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	_, err := tm.tasks[id]
	if !err {
		return ErrTaskNotFound
	} else {
		delete(tm.tasks, id)
	}
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	task, err := tm.tasks[id]
	if !err {
		return Task{}, ErrTaskNotFound
	} else {
		return task, nil
	}
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	tasksList := make([]Task, 0)
	if filterDone != nil {
		for _, task := range tm.tasks {
			if task.Done == *filterDone {
				tasksList = append(tasksList, task)
			}
		}
	} else {
		for _, task := range tm.tasks {
			tasksList = append(tasksList, task)
		}
	}
	return tasksList
}
