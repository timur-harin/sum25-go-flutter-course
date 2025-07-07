package calculator

import (
	"testing"
)

func TestAdd(t *testing.T) {
	tests := []struct {
		name     string
		a, b     float64
		expected float64
	}{
		{"positive numbers", 2, 3, 5},
		{"negative numbers", -2, -3, -5},
		{"mixed numbers", -2, 3, 1},
		{"zeros", 0, 0, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Add(tt.a, tt.b); got != tt.expected {
				t.Errorf("Add(%v, %v) = %v, want %v", tt.a, tt.b, got, tt.expected)
			}
		})
	}
}

func TestSubtract(t *testing.T) {
	tests := []struct {
		name     string
		a, b     float64
		expected float64
	}{
		{"positive numbers", 5, 3, 2},
		{"negative numbers", -5, -3, -2},
		{"mixed numbers", -5, 3, -8},
		{"zeros", 0, 0, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Subtract(tt.a, tt.b); got != tt.expected {
				t.Errorf("Subtract(%v, %v) = %v, want %v", tt.a, tt.b, got, tt.expected)
			}
		})
	}
}

func TestMultiply(t *testing.T) {
	tests := []struct {
		name     string
		a, b     float64
		expected float64
	}{
		{"positive numbers", 2, 3, 6},
		{"negative numbers", -2, -3, 6},
		{"mixed numbers", -2, 3, -6},
		{"zeros", 0, 5, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Multiply(tt.a, tt.b); got != tt.expected {
				t.Errorf("Multiply(%v, %v) = %v, want %v", tt.a, tt.b, got, tt.expected)
			}
		})
	}
}

func TestDivide(t *testing.T) {
	tests := []struct {
		name        string
		a, b        float64
		expected    float64
		expectError bool
	}{
		{"positive numbers", 6, 2, 3, false},
		{"negative numbers", -6, -2, 3, false},
		{"mixed numbers", -6, 2, -3, false},
		{"division by zero", 5, 0, 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := Divide(tt.a, tt.b)
			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != ErrDivisionByZero {
					t.Errorf("Expected ErrDivisionByZero, got %v", err)
				}
			} else {
				if err != nil {
					t.Errorf("Unexpected error: %v", err)
				}
				if got != tt.expected {
					t.Errorf("Divide(%v, %v) = %v, want %v", tt.a, tt.b, got, tt.expected)
				}
			}
		})
	}
}

func TestStringToFloat(t *testing.T) {
	tests := []struct {
		name        string
		input       string
		expected    float64
		expectError bool
	}{
		{"valid integer", "42", 42.0, false},
		{"valid float", "3.14", 3.14, false},
		{"negative number", "-123.45", -123.45, false},
		{"invalid input", "abc", 0, true},
		{"empty string", "", 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := StringToFloat(tt.input)
			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
			} else {
				if err != nil {
					t.Errorf("Unexpected error: %v", err)
				}
				if got != tt.expected {
					t.Errorf("StringToFloat(%q) = %v, want %v", tt.input, got, tt.expected)
				}
			}
		})
	}
}

func TestFloatToString(t *testing.T) {
	tests := []struct {
		name      string
		input     float64
		precision int
		expected  string
	}{
		{"zero precision", 3.14159, 0, "3"},
		{"one decimal", 3.14159, 1, "3.1"},
		{"two decimals", 3.14159, 2, "3.14"},
		{"negative number", -2.5, 1, "-2.5"},
		{"large number", 123456.789, 2, "123456.79"},
		{"zero", 0.0, 2, "0.00"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := FloatToString(tt.input, tt.precision); got != tt.expected {
				t.Errorf("FloatToString(%v, %d) = %v, want %v", tt.input, tt.precision, got, tt.expected)
			}
		})
	}
}
