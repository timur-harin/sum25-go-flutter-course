package calculator

import (
	"errors"
	"fmt"
	"strconv"
)

var ErrDivisionByZero = errors.New("division by zero")

func Add(a, b float64) float64 {
	return a + b
}

func Subtract(a, b float64) float64 {
	return a - b
}

func Multiply(a, b float64) float64 {
	return a * b
}

func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil
}

func StringToFloat(s string) (float64, error) {
	return strconv.ParseFloat(s, 64)
}

func FloatToString(f float64, precision int) string {
	format := fmt.Sprintf("%%.%df", precision)
	return fmt.Sprintf(format, f)
}
