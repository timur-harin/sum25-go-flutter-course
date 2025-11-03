package userdomain

// UserRepository defines the interface for user persistence operations
type UserRepository interface {
	Create(user *User) error
	FindByID(id int) (*User, error)
	FindByEmail(email string) (*User, error)
	Update(user *User) error
	Delete(id int) error
}
