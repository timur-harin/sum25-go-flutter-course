package calculator

import (
	"errors"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add adds two float64 numbers
func Add(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Subtract subtracts b from a
func Subtract(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Multiply multiplies two float64 numbers
func Multiply(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Divide divides a by b, returns an error if b is zero
func Divide(a, b float64) (float64, error) {
	// TODO: Implement this function
	return 0, nil
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	// TODO: Implement this function
	return 0, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	// TODO: Implement this function
	return ""
}
