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

	newTaskManager := TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}

	return &newTaskManager
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {

	if title == "" {
		return nil, ErrEmptyTitle
	}

	newTask := Task{
		tm.nextID,
		title,
		description,
		false,
		time.Now(),
	}

	tm.tasks[tm.nextID] = newTask
	tm.nextID++

	return &newTask, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {

	if title == "" {
		return ErrEmptyTitle
	}

	task, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}

	task.Title = title
	task.Description = description
	task.Done = done
	tm.tasks[id] = task

	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {

	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}

	delete(tm.tasks, id)

	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {

	task, exists := tm.tasks[id]
	if !exists {
		return nil, ErrTaskNotFound
	}

	return &task, nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var tasks []*Task
	for id := range tm.tasks {
		task := tm.tasks[id]
		if filterDone == nil || task.Done == *filterDone {
			tasks = append(tasks, &Task{
				ID:          task.ID,
				Title:       task.Title,
				Description: task.Description,
				Done:        task.Done,
				CreatedAt:   task.CreatedAt,
			})
		}
	}
	return tasks
}
