// race_processor.go handles race creation and validation
package service

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// processRaces handles race creation and returns mapping of race name to race ID
func (s *SyncEmailService) processRaces(ctx context.Context, tx *sql.Tx, races []ParsedRace, emailID int, emailDate string) (map[string]int, int, error) {
	raceNameToID := make(map[string]int)

	if len(races) == 0 {
		return raceNameToID, 0, nil
	}

	s.Logger.Info("Processing %d races", len(races))
	count := 0
	skipped := 0
	for _, parsedRace := range races {
		raceID, inserted, err := s.insertRaceIfNotExists(ctx, tx, parsedRace, emailID, emailDate)
		if err != nil {
			return nil, 0, err
		}
		if inserted {
			count++
		} else if raceID == 0 {
			skipped++
			continue
		}
		raceNameToID[parsedRace.Name] = raceID
	}
	s.Logger.Info("Created %d new races (%d skipped due to missing data)", count, skipped)
	return raceNameToID, count, nil
}

// insertRaceIfNotExists validates, checks existence, and inserts a race if needed
func (s *SyncEmailService) insertRaceIfNotExists(ctx context.Context, tx *sql.Tx, parsedRace ParsedRace, emailID int, emailDate string) (int, bool, error) {
	// Skip races with missing name (date can be empty)
	if parsedRace.Name == "" {
		s.Logger.Debug("Skipping race with missing name")
		return 0, false, nil
	}

	// Extract year from email date
	emailYear := s.extractYearFromEmailDate(emailDate)
	if emailYear == 0 {
		s.Logger.Debug("Could not extract year from email date '%s' for race '%s'", emailDate, parsedRace.Name)
		return 0, false, nil
	}

	// Validate and normalize date (keep for potential backfilling, but don't use for uniqueness)
	raceDate := parsedRace.Date
	if raceDate != "" {
		raceDate = strings.TrimSpace(raceDate)
		if _, err := time.Parse("2006-01-02", raceDate); err != nil {
			s.Logger.Debug("Invalid date format for race '%s': %s, setting to NULL", parsedRace.Name, raceDate)
			raceDate = ""
		}
	}

	// Check if race already exists (by name and year)
	existingID, err := s.DB.CheckRaceExists(ctx, tx, parsedRace.Name, emailYear)
	if err == nil && existingID > 0 {
		return existingID, false, nil
	} else if err != nil && err != sql.ErrNoRows {
		return 0, false, fmt.Errorf("failed to check race existence: %w", err)
	}

	// Create new race
	raceID, err := s.DB.InsertRace(ctx, tx, parsedRace.Name, raceDate, parsedRace.Distance, parsedRace.Type, emailYear, emailID)
	if err != nil {
		return 0, false, fmt.Errorf("failed to insert race %s: %w", parsedRace.Name, err)
	}
	s.Logger.Debug("Created new race: %s (%d, %s) - ID: %d", parsedRace.Name, emailYear, parsedRace.Distance, raceID)
	return raceID, true, nil
}

// extractYearFromEmailDate extracts the year from an email date string
func (s *SyncEmailService) extractYearFromEmailDate(emailDate string) int {
	if emailDate == "" {
		return 0
	}

	// Try to parse as RFC3339 format first (e.g., "2023-12-25T10:30:00Z")
	if t, err := time.Parse(time.RFC3339, emailDate); err == nil {
		return t.Year()
	}

	// Try to parse as date-only format (e.g., "2023-12-25")
	if t, err := time.Parse("2006-01-02", emailDate); err == nil {
		return t.Year()
	}

	// Try to extract year from the beginning of the string
	if len(emailDate) >= 4 {
		if year, err := strconv.Atoi(emailDate[:4]); err == nil && year >= 1900 && year <= 2100 {
			return year
		}
	}

	return 0
}
