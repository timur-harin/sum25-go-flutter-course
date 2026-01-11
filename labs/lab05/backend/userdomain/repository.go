package userdomain

// UserRepository defines the interface for user data access
type UserRepository interface {
	Save(user *User) error
	FindByEmail(email string) (*User, error)
	FindByID(id int) (*User, error)
}
