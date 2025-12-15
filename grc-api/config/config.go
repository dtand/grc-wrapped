package config

import (
	"net/url"
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
	AllowedOrigins     []string
}

// LoadConfig loads configuration from .env file and environment variables
func LoadConfig() *Config {
	_ = godotenv.Load() // Loads .env file if present

	// Heroku uses PORT, but allow SERVER_PORT as fallback for local dev
	port := getEnv("PORT", "")
	if port == "" {
		port = getEnv("SERVER_PORT", "8080")
	}

	// Parse DATABASE_URL if present (Heroku format)
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "grcuser")
	dbPassword := getEnv("DB_PASSWORD", "grcpass")
	dbName := getEnv("DB_NAME", "grcdb")

	if databaseURL := getEnv("DATABASE_URL", ""); databaseURL != "" {
		// Parse Heroku DATABASE_URL: postgres://user:pass@host:port/dbname
		if u, err := url.Parse(databaseURL); err == nil {
			if u.User != nil {
				dbUser = u.User.Username()
				if pass, ok := u.User.Password(); ok {
					dbPassword = pass
				}
			}
			if u.Host != "" {
				parts := strings.Split(u.Host, ":")
				dbHost = parts[0]
				if len(parts) > 1 {
					dbPort = parts[1]
				}
			}
			dbName = strings.TrimPrefix(u.Path, "/")
		}
	}

	cfg := &Config{
		ServerPort:      port,
		DBHost:          dbHost,
		DBPort:          dbPort,
		DBUser:          dbUser,
		DBPassword:      dbPassword,
		DBName:          dbName,
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

	// Parse AllowedOrigins (comma-separated)
	originsStr := getEnv("ALLOWED_ORIGINS", "http://localhost:5173,http://localhost:3000")
	cfg.AllowedOrigins = strings.Split(originsStr, ",")
	for i := range cfg.AllowedOrigins {
		cfg.AllowedOrigins[i] = strings.TrimSpace(cfg.AllowedOrigins[i])
	}

	return cfg
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return strings.TrimSpace(value)
	}
	return fallback
}
