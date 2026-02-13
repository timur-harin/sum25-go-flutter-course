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

type Task struct {
	ID          int
	Title       string
	Description string
	Done        bool
	CreatedAt   time.Time
}

type TaskManager struct {
	tasks  map[int]Task
	nextID int
}

func NewTaskManager() *TaskManager {
	return &TaskManager{
		tasks:  make(map[int]Task),
		nextID: 1,
	}
}

func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	if title == "" {
		return Task{}, ErrEmptyTitle
	}
	task := Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}
	tm.tasks[task.ID] = task
	tm.nextID++
	return task, nil
}

func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	if title == "" {
		return ErrEmptyTitle
	}
	t, exists := tm.tasks[id]
	if !exists {
		return ErrTaskNotFound
	}
	t.Title = title
	t.Description = description
	t.Done = done
	tm.tasks[id] = t
	return nil
}

func (tm *TaskManager) DeleteTask(id int) error {
	if _, exists := tm.tasks[id]; !exists {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

func (tm *TaskManager) GetTask(id int) (Task, error) {
	t, exists := tm.tasks[id]
	if !exists {
		return Task{}, ErrTaskNotFound
	}
	return t, nil
}

func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	result := make([]Task, 0, len(tm.tasks))
	for _, t := range tm.tasks {
		if filterDone == nil || t.Done == *filterDone {
			result = append(result, t)
		}
	}
	return result
}
