package userdomain

// UserRepository defines methods for user persistence
type UserRepository interface {
    FindByID(id int) (*User, error)
    FindByEmail(email string) (*User, error)
    Save(user *User) error
    Update(user *User) error
    Delete(id int) error
}
