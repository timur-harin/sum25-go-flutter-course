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
	newTaskManager := TaskManager{make(map[int]Task), 1}
	return &newTaskManager
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	if len(title) == 0 {
		return Task{}, ErrEmptyTitle
	}
	newTask := Task{tm.nextID, title, description, false, time.Now()}
	tm.tasks[tm.nextID] = newTask
	tm.nextID++
	return newTask, nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if len(title) == 0 {
		return ErrEmptyTitle
	}
	taskToUpdate, ok := tm.tasks[id]
	if ok {
		taskToUpdate.Title = title
		taskToUpdate.Description = description
		taskToUpdate.Done = done
		tm.tasks[id] = taskToUpdate
		return nil
	}
	return ErrTaskNotFound
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	_, ok := tm.tasks[id]
	if ok {
		delete(tm.tasks, id)
		return nil
	}
	return ErrTaskNotFound
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	_, ok := tm.tasks[id]
	if ok {
		return tm.tasks[id], nil
	}
	return Task{}, ErrTaskNotFound
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	tasksFiltered := []Task{}
	tasksNotFiltered := []Task{}
	for _, val := range tm.tasks {
		if filterDone == nil {
			tasksFiltered = append(tasksFiltered, val)
		} else if val.Done == *filterDone {
			tasksFiltered = append(tasksFiltered, val)
		}
	}
	res := append(tasksFiltered, tasksNotFiltered...)
	return res
}
