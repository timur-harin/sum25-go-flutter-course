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
	// TODO: Implement task manager initialization
	return &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1, // Начинаем с ID = 1
	}
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	// TODO: Implement task addition
	var id int = tm.nextID
	curTime := time.Now()
	var task Task = Task{id, title, description, false, curTime}
	tm.tasks[id] = task
	id++
	tm.nextID = id
	if title == "" {
		return &task, ErrEmptyTitle
	}
	return &task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement task update
	if _, ok := tm.tasks[id]; ok {
		tm.tasks[id] = Task{id, title, description, done, tm.tasks[id].CreatedAt}
		if title == "" {
			return ErrEmptyTitle
		}
		return nil
	}
	return ErrTaskNotFound
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
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
	if task, ok := tm.tasks[id]; ok {
		taskCopy := task
		return &taskCopy, nil
	}
	return nil, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var tasks []*Task
	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			taskCopy := task
			tasks = append(tasks, &taskCopy)
		}
	}
	return tasks
}
