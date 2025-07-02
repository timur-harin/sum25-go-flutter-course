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
		taskManager := 	TaskManager {
			nextID: 1,
			tasks: make(map[int]*Task),
		}
	return &taskManager
}

// AddTask adds a new task to the manager
func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == ""{
		return nil ,ErrEmptyTitle
	}
	task := Task {
		ID: tm.nextID,
		Title: title,
		Description: description,
		Done: false,
		CreatedAt: time.Now(),
	}
	tm.tasks[tm.nextID] = &task
	tm.nextID +=1
	return &task, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if (tm.tasks[id] == nil){
		return ErrTaskNotFound
	}
	if tm.nextID <= id || id < 0 {
		return ErrInvalidID
	}
	if title == ""{
		return ErrEmptyTitle
	}
	task := tm.tasks[id]
	task.Title = title
	task.Description = description
	task.Done = done
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	if (tm.tasks[id] == nil){
		return ErrTaskNotFound
	}
	 delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID
func (tm *TaskManager) GetTask(id int) (*Task, error) {
	if (tm.tasks[id] == nil){
		return nil, ErrTaskNotFound
	} 
	if tm.nextID <= id || id < 0 {
		return nil, ErrInvalidID
	}
	return tm.tasks[id], nil
}

// ListTasks returns all tasks, optionally filtered by done status
func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var doneTasks []*Task
	for i :=0; i<len(tm.tasks); i++{
		doneTasks = append(doneTasks, tm.tasks[i])
	}
	return doneTasks
}
