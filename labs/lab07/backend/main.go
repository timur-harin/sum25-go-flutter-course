package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello, World from Go & Flutter summer elective course!")
}

func main() {
	fmt.Println("Hello, World from Go & Flutter summer elective course!")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}