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
	tm := new(TaskManager)
	tm.tasks = make(map[int]Task)
	tm.nextID = 1
	return tm
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	var t Task
	if title == "" {
		return t, ErrEmptyTitle
	}
	t.ID = tm.nextID
	tm.nextID++
	t.Title = title
	t.Description = description
	t.CreatedAt = time.Now()
	tm.tasks[t.ID] = t
	return t, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	}
	task, err := tm.GetTask(id)
	if err != nil {
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
	_, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	task, exists := tm.tasks[id]
	if !exists {
		return task, ErrTaskNotFound
	}
	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	var tasks []Task
	for _, task := range tm.tasks {
		if filterDone == nil {
			tasks = append(tasks, task)
		} else if *filterDone == task.Done {
			tasks = append(tasks, task)
		}
	}
	return tasks
}
