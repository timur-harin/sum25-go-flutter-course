package calculator

import (
	"errors"
	"fmt"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add adds two float64 numbers
func Add(a, b float64) float64 {
<<<<<<< HEAD
	// TODO: Implement this function
	return 0
=======
	return a + b
>>>>>>> 8441780 (lab01 solution)
}

// Subtract subtracts b from a
func Subtract(a, b float64) float64 {
<<<<<<< HEAD
	// TODO: Implement this function
	return 0
=======
	return a - b
>>>>>>> 8441780 (lab01 solution)
}

// Multiply multiplies two float64 numbers
func Multiply(a, b float64) float64 {
<<<<<<< HEAD
	// TODO: Implement this function
	return 0
=======
	return a * b
>>>>>>> 8441780 (lab01 solution)
}

// Divide divides a by b, returns an error if b is zero
func Divide(a, b float64) (float64, error) {
<<<<<<< HEAD
	// TODO: Implement this function
	return 0, nil
=======
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil
>>>>>>> 8441780 (lab01 solution)
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
<<<<<<< HEAD
	// TODO: Implement this function
	return 0, nil
=======
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}
	return f, nil
>>>>>>> 8441780 (lab01 solution)
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
<<<<<<< HEAD
	// TODO: Implement this function
	return ""
=======
	format := fmt.Sprintf("%%.%df", precision)
	return fmt.Sprintf(format, f)
>>>>>>> 8441780 (lab01 solution)
}
