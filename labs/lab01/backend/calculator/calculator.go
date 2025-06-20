package calculator

import (
	"errors"
	"fmt"
	"strconv"
)

var ErrDivisionByZero = errors.New("division by zero")

func Add(a, b float64) float64 {
	fmt.Print(a + b)
	return a + b
}

func Subtract(a, b float64) float64 {
	fmt.Print(a - b)
	return a - b
}

func Multiply(a, b float64) float64 {
	fmt.Print(a * b)
	return a * b
}

func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	fmt.Print(a / b)
	return a / b, nil
}

func StringToFloat(s string) (float64, error) {
	float, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}
	fmt.Print(float)
	return float, nil
}

func FloatToString(f float64, precision int) string {
	str := strconv.FormatFloat(f, 'f', precision, 64)
	fmt.Print(str)
	return str
}

//
//func main() {
//	var a, b float64
//	fmt.Scan(&a, &b)
//	Add(a, b)
//	Subtract(a, b)
//	Divide(a, b)
//	Multiply(a, b)
//	var s string
//	fmt.Scan(&s)
//	StringToFloat(s)
//	var fl float64
//	var precision int
//	fmt.Scan(fl, precision)
//	//FloatToString(fl, precision)
//}
