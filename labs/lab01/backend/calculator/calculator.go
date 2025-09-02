package calculator

import (
	"errors"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// ErrInvlidFormat is returned when input string cannot be converted to float
var ErrInvalidFormat = errors.New("invalid format")

// Add returns the sum of two numbers
func Add(a, b float64) float64 {
	return a + b
}

// Subtract returns the difference between two numbers
func Subtract(a, b float64) float64 {
	return a - b
}

// Multiply returns the product of two numbers
func Multiply(a, b float64) float64 {
	return a * b
}

// Divide returns the quotient of two numbers
// Returns ErrDivisionByZero if denominator (b) is zero
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	} else {
		return a / b, nil
	}
}

// StringToFloat converts a string to float64
// Returns ErrInvlidFormat if the string is empty or not a valid number
func StringToFloat(s string) (float64, error) {
	if s == "" {
		return 0, ErrInvalidFormat
	}

	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, ErrInvalidFormat
	}
	return f, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	return strconv.FormatFloat(f, 'f', precision, 64)
}
