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
	var taskManager *TaskManager = &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 0,
	}
	taskManager.nextID++
	return taskManager
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	if title == "" {
		return Task{}, ErrEmptyTitle
	}
	var task Task = Task{tm.nextID, title, description, false, time.Now()}
	tm.tasks[tm.nextID] = task
	tm.nextID++
	return task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if id < 0 {
		return ErrTaskNotFound
	}
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
	if id < 0 {
		return ErrTaskNotFound
	}
	if _, ok := tm.tasks[id]; ok {
		delete(tm.tasks, id)
		return nil
	}
	return ErrTaskNotFound
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	if id < 0 {
		return Task{}, ErrTaskNotFound
	}
	if task, ok := tm.tasks[id]; ok {
		return task, nil
	}
	return Task{}, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	var doneTasks []Task = make([]Task, 0)
	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			doneTasks = append(doneTasks, task)
		}
	}
	return doneTasks
}
