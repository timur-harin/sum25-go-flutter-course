package taskmanager

import (
	"errors"
	"time"
)

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
	tasks  map[int]*Task
	nextID int
}

func NewTaskManager() *TaskManager {
	return &TaskManager{
		tasks:  make(map[int]*Task),
		nextID: 1,
	}
}

func (tm *TaskManager) AddTask(title, description string) (*Task, error) {
	if title == "" {
		return nil, ErrEmptyTitle
	}
	task := &Task{
		ID:          tm.nextID,
		Title:       title,
		Description: description,
		Done:        false,
		CreatedAt:   time.Now(),
	}
	tm.tasks[tm.nextID] = task
	tm.nextID++
	return task, nil
}

func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	task, ok := tm.tasks[id]
	if !ok {
		return ErrTaskNotFound
	}
	if title == "" {
		return ErrEmptyTitle
	}
	task.Title = title
	task.Description = description
	task.Done = done
	return nil
}

func (tm *TaskManager) DeleteTask(id int) error {
	if _, ok := tm.tasks[id]; !ok {
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

func (tm *TaskManager) GetTask(id int) (*Task, error) {
	task, ok := tm.tasks[id]
	if !ok {
		return nil, ErrTaskNotFound
	}
	return task, nil
}

func (tm *TaskManager) ListTasks(filterDone *bool) []*Task {
	var result []*Task
	for _, task := range tm.tasks {
		if filterDone == nil || task.Done == *filterDone {
			result = append(result, task)
		}
	}
	return result
}
