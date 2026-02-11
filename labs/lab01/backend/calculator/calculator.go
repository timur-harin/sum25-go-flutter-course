package calculator

import (
	"errors"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add adds two float64 numbers
func Add(a, b float64) float64 {
	// TODO: Implement this function
	return a + b
}

// Subtract subtracts b from a
func Subtract(a, b float64) float64 {
	// TODO: Implement this function
	return a - b
}

// Multiply multiplies two float64 numbers
func Multiply(a, b float64) float64 {
	// TODO: Implement this function
	return a * b
}

// Divide divides a by b, returns an error if b is zero
func Divide(a, b float64) (float64, error) {
	// TODO: Implement this function
	if b == 0 {
		return 0, ErrDivisionByZero // returning error message as the denominator equals zero
	}
	return a / b, nil
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	// TODO: Implement this function
	number, err := strconv.ParseFloat(s, 64) // converting from the type string to the type float64
	if err != nil {                          // if the error was detected then we return the corresponding message
		return 0, err
	}
	return number, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	// TODO: Implement this function
	s := strconv.FormatFloat(f, 'f', precision, 64) // converting from the float64 type format to the string
	return s
}
