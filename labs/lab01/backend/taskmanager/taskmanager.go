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
	// TODO: Implement this function
	return &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement this function
	if title == "" {
		return Task{}, ErrEmptyTitle
	}
	t := Task{}
	id := tm.nextID
	t.Title = title
	t.Description = description
	t.CreatedAt = time.Now()
	t.ID = id
	tm.tasks[tm.nextID] = t
	tm.nextID = tm.nextID + 1
	return tm.tasks[id], nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement this functions
	_, ok := tm.tasks[id]
	if !ok { // if the task with this id does not exist, then we return an error message
		return ErrTaskNotFound
	}
	if title == "" { // if the title is empty, then we return an error message
		return ErrEmptyTitle
	}
	task := tm.tasks[id] //assigning data to the new instance of type struct Task
	task.Title = title
	task.Description = description
	task.Done = done
	task.ID = id
	tm.tasks[id] = task
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement this function
	_, ok := tm.tasks[id]
	if !ok { // if the task with this id does not exist, then we return an error message
		return ErrTaskNotFound
	}
	delete(tm.tasks, id) // deleting the instance of type struct Task
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	// TODO: Implement this function
	task, found := tm.tasks[id]
	if !found { // if the error was detected, we return the corresponding message
		return Task{}, ErrTaskNotFound
	}
	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	// TODO: Implement this function
	var tasks []Task = []Task{}
	if filterDone == nil { // if no condiiton was provided, then all instance of type struct Task will be added to the slice
		for _, value := range tm.tasks {
			tasks = append(tasks, value)
		}
	} else { // some condition exists, it means that some tasks are not appended to the final slice
		for _, value := range tm.tasks {
			if value.Done == *filterDone {
				tasks = append(tasks, value)
			}
		}
	}
	return tasks
}
