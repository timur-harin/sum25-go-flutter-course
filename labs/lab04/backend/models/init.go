package models

import (
	"errors"

	"github.com/go-playground/validator/v10"
)

var (
	validate = validator.New(validator.WithRequiredStructEnabled())
	errNilRow = errors.New("row is nil")
	errNilRows = errors.New("rows are nil")
)

// register custom validation functions
func init() {
	validate.RegisterValidation("required_if_published", validatePublishedContent)
}