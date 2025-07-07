package taskmanager

import (
	"errors"
	"time"
)

// func main() {
// 	var tm TaskManager = *NewTaskManager();

// 	tm.AddTask("Task 1", "hehe")
// 	tm.AddTask("Task 2", "hehe")

// 	fmt.Println(tm.ListTasks(nil))

// }

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

	TM := &TaskManager{
		tasks: make(map[int]Task),
		nextID: 1,
	}
	return TM
}

// AddTask adds a new task to the manager, returns an error if the title is empty, and increments the nextID
func (tm *TaskManager) AddTask(title, description string) (Task, error) {
	// TODO: Implement this function
	if(len(title) == 0){
		return Task{}, ErrEmptyTitle
	}
	tm.tasks[tm.nextID] = Task{
			ID: tm.nextID,
			Title: title,
			Description: description,
			Done: false,
			CreatedAt: time.Now(),
		}
	tm.nextID++
	return tm.tasks[tm.nextID-1], nil
}

// UpdateTask updates an existing task, returns an error if the title is empty or the task is not found
func (tm *TaskManager) UpdateTask(id int, title, description string, done bool) error {
	// TODO: Implement this function
	task, exists := tm.tasks[id]
	if(!exists || id <= 0){
		return ErrTaskNotFound
	}
	if len(title)==0 {
		return ErrEmptyTitle
	}
	newTask := Task{
			ID: id,
			Title: title,
			Description: description,
			Done: done,
			CreatedAt: task.CreatedAt,
		}
	tm.tasks[id] = newTask
	return nil
}

// DeleteTask removes a task from the manager, returns an error if the task is not found
func (tm *TaskManager) DeleteTask(id int) error {
	// TODO: Implement this function
	_, exists := tm.tasks[id]
	if (!exists || id <= 0){
		return ErrTaskNotFound
	}
	delete(tm.tasks, id)
	return nil
}

// GetTask retrieves a task by ID, returns an error if the task is not found
func (tm *TaskManager) GetTask(id int) (Task, error) {
	// TODO: Implement this function
	task, exists := tm.tasks[id]
	if(!exists || id <= 0){
		return Task{}, ErrTaskNotFound
	}

	return task, nil
}

// ListTasks returns all tasks, optionally filtered by done status, returns an empty slice if no tasks are found
func (tm *TaskManager) ListTasks(filterDone *bool) []Task {
	var list []Task

	for _, task := range tm.tasks {
		if filterDone == nil || *filterDone == task.Done {
			list = append(list, task)
		}
	}
	// TODO: Implement this function
	return list
}
