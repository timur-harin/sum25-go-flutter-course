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
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil

}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	f64, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}
	return f64, nil
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	return fmt.Sprintf("%.*f", precision, f)
}
