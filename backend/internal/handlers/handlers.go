package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// HealthCheck returns server health status
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "sum25-go-flutter-course-backend",
		"version": "1.0.0",
	})
}

// Ping returns a simple pong response
func Ping(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "pong",
	})
}
