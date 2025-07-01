package calculator

import (
	"errors"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add returns the sum of two numbers
func Add(a, b float64) float64 {
	// TODO: Implement addition
	return 0
}

// Subtract returns the difference between two numbers
func Subtract(a, b float64) float64 {
	// TODO: Implement subtraction
	return 0
}

// Multiply returns the product of two numbers
func Multiply(a, b float64) float64 {
	// TODO: Implement multiplication
	return 0
}

// Divide returns the quotient of two numbers
func Divide(a, b float64) (float64, error) {
	// TODO: Implement division with error handling
	return 0, nil
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	// TODO: Implement string to float conversion
	return 0, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	// TODO: Implement float to string conversion
	return ""
}
