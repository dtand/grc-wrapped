package service

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/grcwrapped/grcapi/config"
	"github.com/grcwrapped/grcapi/internal/db"
	"github.com/grcwrapped/grcapi/internal/models"
)

// Logger provides leveled logging
type Logger struct {
	level string
}

// NewLogger creates a new logger with the given level
func NewLogger(level string) *Logger {
	return &Logger{level: level}
}

// shouldLog checks if the given level should be logged
func (l *Logger) shouldLog(msgLevel string) bool {
	levels := map[string]int{"debug": 0, "info": 1, "warn": 2, "error": 3}
	msgLvl, ok := levels[msgLevel]
	if !ok {
		return false
	}
	cfgLvl, ok := levels[l.level]
	if !ok {
		return msgLvl >= 1 // default to info
	}
	return msgLvl >= cfgLvl
}

// Debug logs debug messages
func (l *Logger) Debug(format string, args ...interface{}) {
	if l.shouldLog("debug") {
		log.Printf("[DEBUG] "+format, args...)
	}
}

// Info logs info messages
func (l *Logger) Info(format string, args ...interface{}) {
	if l.shouldLog("info") {
		log.Printf("[INFO] "+format, args...)
	}
}

// Warn logs warn messages
func (l *Logger) Warn(format string, args ...interface{}) {
	if l.shouldLog("warn") {
		log.Printf("[WARN] "+format, args...)
	}
}

// Error logs error messages
func (l *Logger) Error(format string, args ...interface{}) {
	if l.shouldLog("error") {
		log.Printf("[ERROR] "+format, args...)
	}
}

// SyncEmailResult holds the result of syncing emails
type SyncEmailResult struct {
	EmailsProcessed int
	RecordsCreated  map[string]int
	Errors          []string
}

// EmailWithParsedData pairs email metadata with parsed LLM data
type EmailWithParsedData struct {
	Email      *models.Email
	ParsedData *ParsedEmailData
}

// SyncEmailService struct holds dependencies for syncing emails
type SyncEmailService struct {
	DB             *db.DB
	Config         *config.Config
	FetchEmailsSvc *FetchEmailsService
	LLMParserSvc   *LLMParserService
	AthleteMatcher *AthleteMatcherService
	Logger         *Logger
}

func NewSyncEmailService(database *db.DB, cfg *config.Config, fetchEmailsSvc *FetchEmailsService, llmParserSvc *LLMParserService, athleteMatcher *AthleteMatcherService) *SyncEmailService {
	return &SyncEmailService{
		DB:             database,
		Config:         cfg,
		FetchEmailsSvc: fetchEmailsSvc,
		LLMParserSvc:   llmParserSvc,
		AthleteMatcher: athleteMatcher,
		Logger:         NewLogger(cfg.LogLevel),
	}
}

// SyncEmails is responsible for fetching, parsing, and syncing emails
func (s *SyncEmailService) SyncEmails(ctx context.Context, startDate, sender, recipient string) (*SyncEmailResult, error) {
	s.Logger.Info("Starting email sync - startDate: %s, sender: %s, recipient: %s", startDate, sender, recipient)

	// Fetch emails using the fetch_emails_service
	fetchedEmails, err := s.FetchEmailsSvc.FetchFilteredEmails(ctx, sender, recipient, startDate)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch emails: %v", err)
	}
	s.Logger.Info("Fetched %d emails from IMAP", len(fetchedEmails))

	// Convert to models.Email with validation
	emails := make([]*models.Email, 0, len(fetchedEmails))
	validCount := 0
	for _, e := range fetchedEmails {
		email := &models.Email{
			ID:        0, // Set if saving to DB
			Title:     e.Subject,
			Body:      e.Body,
			Date:      e.Date.Format("2006-01-02T15:04:05Z07:00"),
			Sender:    e.From,
			Recipient: e.To,
		}

		// Log warning for empty bodies
		if strings.TrimSpace(email.Body) == "" {
			s.Logger.Warn("Fetched email with empty body - Subject: '%s', Sender: %s", email.Title, email.Sender)
		}

		// Validate email before adding to processing list
		if s.isValidEmailForProcessing(email) {
			emails = append(emails, email)
			validCount++
		} else {
			s.Logger.Debug("Skipping invalid email: '%s' from %s", email.Title, email.Sender)
		}
	}

	validationFilteredCount := len(fetchedEmails) - validCount
	if validationFilteredCount > 0 {
		s.Logger.Info("Filtered out %d invalid emails during validation, %d remaining", validationFilteredCount, validCount)
	}

	// Filter out emails that have already been processed
	unprocessedEmails, err := s.filterAlreadyProcessedEmails(ctx, emails)
	if err != nil {
		return nil, fmt.Errorf("failed to filter emails: %v", err)
	}
	filteredCount := len(emails) - len(unprocessedEmails)
	s.Logger.Info("Filtered out %d already-processed emails, %d remaining to process", filteredCount, len(unprocessedEmails))

	// Initialize result tracking
	result := &SyncEmailResult{
		EmailsProcessed: 0,
		RecordsCreated: map[string]int{
			"athletes":     0,
			"races":        0,
			"race_results": 0,
			"workouts":     0,
		},
		Errors: []string{},
	}

	// Process each email sequentially to avoid API rate limits
	s.Logger.Info("Starting sequential email processing")

	for i, email := range unprocessedEmails {
		s.Logger.Info("Processing email %d/%d: '%s'", i+1, len(unprocessedEmails), email.Title)

		// Parse with LLM (with retry)
		var parsed *ParsedEmailData
		var prompt, response string
		maxRetries := s.Config.MaxRetries
		for attempt := 1; attempt <= maxRetries; attempt++ {
			var err error
			parsed, prompt, response, err = s.LLMParserSvc.ParseEmailWithDebug(ctx, email)

			// Always log the prompt and response for review
			if logErr := s.logPromptAndResponse(email, prompt, response, attempt, err); logErr != nil {
				s.Logger.Error("Failed to log prompt and response: %v", logErr)
			}

			if err == nil {
				break
			}

			// Log debug information on failure
			if logErr := s.logParsingFailure(email, prompt, response, attempt, err); logErr != nil {
				s.Logger.Error("Failed to log parsing failure: %v", logErr)
			}

			if attempt < maxRetries {
				s.Logger.Info("LLM parsing attempt %d failed for email '%s': %v, retrying in %v...", attempt, email.Title, err, s.Config.RetrySleepDuration)
				select {
				case <-time.After(s.Config.RetrySleepDuration):
				case <-ctx.Done():
					s.Logger.Info("Context canceled during retry for email '%s'", email.Title)
					result.Errors = append(result.Errors, "Context canceled")
					return result, nil
				}
			} else {
				errMsg := fmt.Sprintf("Error parsing email '%s' after %d attempts: %v", email.Title, maxRetries, err)
				s.Logger.Error("ERROR: %s", errMsg)
				result.Errors = append(result.Errors, errMsg)
				parsed = nil // Ensure parsed is nil on failure
			}
		}
		if parsed == nil {
			continue // Skip to next email if parsing failed
		}

		// Filter races to only include those that have at least one race result
		raceNamesWithResults := make(map[string]bool)
		for _, result := range parsed.RaceResults {
			raceNamesWithResults[result.RaceName] = true
		}

		filteredRaces := make([]ParsedRace, 0)
		for _, race := range parsed.Races {
			if raceNamesWithResults[race.Name] {
				filteredRaces = append(filteredRaces, race)
			}
		}
		parsed.Races = filteredRaces
		s.Logger.Info("Parsed email '%s': %d athletes, %d races, %d race results, %d workouts",
			email.Title, len(parsed.Athletes), len(parsed.Races), len(parsed.RaceResults), len(parsed.Workouts))

		// Immediately populate to database
		emailData := &EmailWithParsedData{
			Email:      email,
			ParsedData: parsed,
		}

		err = s.processEmailInTransaction(ctx, emailData, result)
		if err != nil {
			errMsg := fmt.Sprintf("Failed to process email '%s': %v", email.Title, err)
			s.Logger.Error("ERROR: %s", errMsg)
			result.Errors = append(result.Errors, errMsg)
			continue // Skip to next email instead of failing completely
		}

		result.EmailsProcessed++
		s.Logger.Info("Successfully committed email '%s' to database", email.Title)

		// Sleep between emails to throttle API requests
		time.Sleep(s.Config.SleepBetweenEmails)
	}

	s.Logger.Info("Email sync completed - %d/%d emails processed successfully", result.EmailsProcessed, len(unprocessedEmails))
	return result, nil
}

// filterAlreadyProcessedEmails removes emails that have already been processed based on title and date
func (s *SyncEmailService) filterAlreadyProcessedEmails(ctx context.Context, emails []*models.Email) ([]*models.Email, error) {
	unprocessed := make([]*models.Email, 0)

	for _, email := range emails {
		// Normalize title and date for robust deduplication
		normalizedTitle := strings.TrimSpace(strings.ToLower(email.Title))
		normalizedDate := strings.TrimSpace(email.Date)

		exists, err := s.DB.CheckEmailExists(ctx, normalizedTitle, normalizedDate)
		if err != nil {
			return nil, fmt.Errorf("failed to check if email exists: %w", err)
		}

		if !exists {
			unprocessed = append(unprocessed, email)
		}
	}

	return unprocessed, nil
}

// processEmailInTransaction handles a single email within a database transaction
func (s *SyncEmailService) processEmailInTransaction(ctx context.Context, emailData *EmailWithParsedData, result *SyncEmailResult) error {
	if emailData == nil || emailData.ParsedData == nil {
		return fmt.Errorf("emailData or ParsedData is nil")
	}

	if ctx.Err() != nil {
		return ctx.Err()
	}

	// Phase 1: Transaction Setup
	tx, err := s.DB.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Phase 2: Email Persistence
	emailID, err := s.persistEmail(ctx, tx, emailData.Email)
	if err != nil {
		return err
	}

	// Phase 3: Athlete Processing
	if ctx.Err() != nil {
		return ctx.Err()
	}
	athleteCount, err := s.processAthletes(ctx, tx, emailData.ParsedData.Athletes)
	if err != nil {
		return err
	}
	result.RecordsCreated["athletes"] += athleteCount

	// Phase 4: Race Processing
	if ctx.Err() != nil {
		return ctx.Err()
	}
	raceNameToID, raceCount, err := s.processRaces(ctx, tx, emailData.ParsedData.Races, emailID, emailData.Email.Date)
	if err != nil {
		return err
	}
	result.RecordsCreated["races"] += raceCount

	// Phase 5: Race Results Processing
	if ctx.Err() != nil {
		return ctx.Err()
	}
	raceResultCount, err := s.processRaceResults(ctx, tx, emailData.ParsedData.RaceResults, raceNameToID, emailID)
	if err != nil {
		return err
	}
	result.RecordsCreated["race_results"] += raceResultCount

	// Phase 6: Workout Processing
	if ctx.Err() != nil {
		return ctx.Err()
	}
	workoutCount, err := s.processWorkouts(ctx, tx, emailData.ParsedData.Workouts, emailID)
	if err != nil {
		return err
	}
	result.RecordsCreated["workouts"] += workoutCount

	// Phase 7: Commit Transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}

// persistEmail saves email metadata to the database
func (s *SyncEmailService) persistEmail(ctx context.Context, tx *sql.Tx, email *models.Email) (int, error) {
	emailID, err := s.DB.InsertEmail(ctx, tx, email.Title, email.Body, email.Date, email.Sender, email.Recipient)
	if err != nil {
		return 0, fmt.Errorf("failed to insert email: %w", err)
	}
	s.Logger.Debug("Persisted email with ID: %d", emailID)
	return emailID, nil
}

// isValidEmailForProcessing validates if an email should be processed for workout/race data
func (s *SyncEmailService) isValidEmailForProcessing(email *models.Email) bool {
	// Basic checks
	if email.Body == "" || strings.TrimSpace(email.Body) == "" {
		return false
	}

	body := strings.ToLower(email.Body)
	subject := strings.ToLower(email.Title)

	if strings.Contains(subject, "re:") || strings.Contains(subject, "fwd:") {
		return false
	}

	// Minimum content length (avoid very short emails)
	if len(body) < 200 {
		return false
	}

	// Check for expected content patterns
	hasWorkoutContent := strings.Contains(body, "workout") ||
		strings.Contains(body, "warmup") ||
		strings.Contains(body, "meet at") ||
		strings.Contains(subject, "workout")

	hasRaceContent := strings.Contains(body, "race") ||
		strings.Contains(body, "pr") ||
		strings.Contains(body, "personal record") ||
		strings.Contains(body, "marathon") ||
		strings.Contains(body, "half marathon")

	hasAthleteContent := strings.Contains(body, "ran") ||
		strings.Contains(body, "finished") ||
		strings.Contains(body, "placed") ||
		strings.Contains(body, "minute") ||
		strings.Contains(body, "second")

	// Must have at least one type of relevant content
	if !hasWorkoutContent && !hasRaceContent && !hasAthleteContent {
		return false
	}

	return true
}

// logPromptAndResponse writes prompt and response details to a local file for review
func (s *SyncEmailService) logPromptAndResponse(email *models.Email, prompt, response string, attempt int, parseErr error) error {
	// Sanitize filename components
	emailDate := strings.ReplaceAll(email.Date[:10], "-", "") // YYYY-MM-DD -> YYYYMMDD
	emailTitle := strings.ReplaceAll(strings.ReplaceAll(email.Title, " ", "_"), "/", "_")
	filename := fmt.Sprintf("%s-%s-%d.prompt", emailDate, emailTitle, attempt)

	// Create debug directory if it doesn't exist
	debugDir := "debug_logs"
	if err := os.MkdirAll(debugDir, 0755); err != nil {
		return fmt.Errorf("failed to create debug directory: %w", err)
	}

	filepath := fmt.Sprintf("%s/%s", debugDir, filename)

	status := "SUCCESS"
	if parseErr != nil {
		status = "FAILED"
	}

	content := fmt.Sprintf("EMAIL PARSING DEBUG INFO\n========================\n\nEmail Date: %s\nEmail Title: %s\nEmail Sender: %s\nAttempt: %d\nStatus: %s\n",
		email.Date, email.Title, email.Sender, attempt, status)

	if parseErr != nil {
		content += fmt.Sprintf("Error: %v\n\n", parseErr)
	} else {
		content += "Error: <nil>\n\n"
	}

	content += fmt.Sprintf("PROMPT SENT TO LLM:\n===================\n%s\n\nLLM RESPONSE:\n=============\n%s\n", prompt, response)

	if err := os.WriteFile(filepath, []byte(content), 0644); err != nil {
		return fmt.Errorf("failed to write debug log file %s: %w", filepath, err)
	}

	s.Logger.Info("Logged prompt and response to %s", filepath)
	return nil
}

// logParsingFailure writes debug information for LLM parsing failures
func (s *SyncEmailService) logParsingFailure(email *models.Email, prompt, response string, attempt int, err error) error {
	if email == nil {
		return fmt.Errorf("email is nil")
	}

	// Create debug directory if it doesn't exist
	debugDir := "debug_logs"
	if err := os.MkdirAll(debugDir, 0755); err != nil {
		return fmt.Errorf("failed to create debug directory: %w", err)
	}

	// Sanitize filename components
	emailDate := strings.ReplaceAll(email.Date[:10], "-", "") // YYYYMMDD format
	emailTitle := strings.ReplaceAll(strings.ReplaceAll(email.Title, " ", "_"), "/", "_")
	filename := fmt.Sprintf("%s-%s-%d.err", emailDate, emailTitle, attempt)
	filepath := filepath.Join(debugDir, filename)

	// Write debug information to file
	file, err := os.Create(filepath)
	if err != nil {
		return fmt.Errorf("failed to create debug file: %w", err)
	}
	defer file.Close()

	debugInfo := fmt.Sprintf("EMAIL PARSING FAILURE DEBUG INFO\n")
	debugInfo += fmt.Sprintf("================================\n\n")
	debugInfo += fmt.Sprintf("Email Date: %s\n", email.Date)
	debugInfo += fmt.Sprintf("Email Title: %s\n", email.Title)
	debugInfo += fmt.Sprintf("Email Sender: %s\n", email.Sender)
	debugInfo += fmt.Sprintf("Attempt: %d\n", attempt)
	debugInfo += fmt.Sprintf("Error: %v\n\n", err)
	debugInfo += fmt.Sprintf("PROMPT SENT TO LLM:\n")
	debugInfo += fmt.Sprintf("===================\n")
	debugInfo += fmt.Sprintf("%s\n\n", prompt)
	debugInfo += fmt.Sprintf("LLM RESPONSE:\n")
	debugInfo += fmt.Sprintf("=============\n")
	debugInfo += fmt.Sprintf("%s\n", response)

	if _, err := file.WriteString(debugInfo); err != nil {
		return fmt.Errorf("failed to write debug info: %w", err)
	}

	s.Logger.Info("Debug information written to %s", filepath)
	return nil
}

// processWorkouts handles workout, group, and segment creation
