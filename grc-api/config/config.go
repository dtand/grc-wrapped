package config

import (
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

// Config holds application configuration
type Config struct {
	ServerPort         string
	DBHost             string
	DBPort             string
	DBUser             string
	DBPassword         string
	DBName             string
	AdminAPIKey        string
	AnthropicAPIKey    string
	GmailEmail         string
	GmailPassword      string
	MaxRetries         int
	RetrySleepDuration time.Duration
	LogLevel           string
	SleepBetweenEmails time.Duration
}

// LoadConfig loads configuration from .env file and environment variables
func LoadConfig() *Config {
	_ = godotenv.Load() // Loads .env file if present

	cfg := &Config{
		ServerPort:      getEnv("SERVER_PORT", "8080"),
		DBHost:          getEnv("DB_HOST", "localhost"),
		DBPort:          getEnv("DB_PORT", "5432"),
		DBUser:          getEnv("DB_USER", "grcuser"),
		DBPassword:      getEnv("DB_PASSWORD", "grcpass"),
		DBName:          getEnv("DB_NAME", "grcdb"),
		AdminAPIKey:     getEnv("ADMIN_API_KEY", ""),
		AnthropicAPIKey: getEnv("ANTHROPIC_API_KEY", ""),
		GmailEmail:      getEnv("GMAIL_EMAIL", ""),
		GmailPassword:   getEnv("GMAIL_APP_PASSWORD", ""),
	}

	// Parse MaxRetries
	maxRetriesStr := getEnv("MAX_RETRIES", "3")
	maxRetries, err := strconv.Atoi(maxRetriesStr)
	if err != nil {
		maxRetries = 3
	}
	cfg.MaxRetries = maxRetries

	// Parse RetrySleepDuration
	retrySleepStr := getEnv("RETRY_SLEEP_DURATION", "2s")
	retrySleep, err := time.ParseDuration(retrySleepStr)
	if err != nil {
		retrySleep = 2 * time.Second
	}
	cfg.RetrySleepDuration = retrySleep

	// Parse SleepBetweenEmails
	sleepStr := getEnv("SLEEP_BETWEEN_EMAILS", "1s")
	sleepDuration, err := time.ParseDuration(sleepStr)
	if err != nil {
		sleepDuration = time.Second
	}
	cfg.SleepBetweenEmails = sleepDuration

	// Set LogLevel
	cfg.LogLevel = getEnv("LOG_LEVEL", "info")

	return cfg
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return strings.TrimSpace(value)
	}
	return fallback
}
