package calculator

import (
	"errors"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

// Add returns the sum of two numbers
func Add(a, b float64) float64 {
	var result float64 = a + b
	return result
}

// Subtract returns the difference between two numbers
func Subtract(a, b float64) float64 {
	var result float64 = a - b
	return result
}

// Multiply returns the product of two numbers
func Multiply(a, b float64) float64 {
	var result float64 = a * b
	return result
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
	return strconv.ParseFloat(s, 64)
}

// FloatToString converts a float64 to string with specified precision
func FloatToString(f float64, precision int) string {
	return strconv.FormatFloat(f, byte('g'), precision, 64)
}
