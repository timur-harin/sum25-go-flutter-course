package calculator

import (
	"errors"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add adds two float64 numbers
func Add(a, b float64) float64 {
	// TODO: Implement addition
	return a + b
}

// Subtract subtracts b from a
func Subtract(a, b float64) float64 {
	// TODO: Implement subtraction
	return a - b
}

// Multiply multiplies two float64 numbers
func Multiply(a, b float64) float64 {
	// TODO: Implement multiplication
	return a * b
}

// Divide divides a by b, returns an error if b is zero
func Divide(a, b float64) (float64, error) {
	// TODO: Implement division with error handling
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	// TODO: Implement string to float conversion
	fNum, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}
	return fNum, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	// TODO: Implement float to string conversion
	return strconv.FormatFloat(f, 'f', precision, 64)
}
