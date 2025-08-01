package calculator

import (
	"errors"
	"math"
	"strconv"
)

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = errors.New("division by zero")

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
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return math.NaN(), ErrDivisionByZero
	}

	return a / b, nil
}

// StringToFloat converts a string to float64
func StringToFloat(s string) (float64, error) {
	if res, err := strconv.ParseFloat(s, 64); err == nil {
		return res, nil
	} else {
		return math.NaN(), err
	}
}

func FloatToString(f float64, precision int) string {
	str := strconv.FormatFloat(f, 'f', precision, 64)
	return str
}
