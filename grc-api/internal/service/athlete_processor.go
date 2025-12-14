// athlete_processor.go handles athlete creation and deduplication
package service

import (
	"context"
	"database/sql"
	"fmt"
)

// processAthletes handles athlete creation (de-duplicated)
func (s *SyncEmailService) processAthletes(ctx context.Context, tx *sql.Tx, athletes []ParsedAthlete) (int, error) {
	if len(athletes) == 0 {
		return 0, nil
	}

	s.Logger.Info("Processing %d athletes", len(athletes))
	count := 0
	for _, parsedAthlete := range athletes {
		inserted, err := s.insertAthleteIfNotExists(ctx, tx, parsedAthlete)
		if err != nil {
			return 0, err
		}
		if inserted {
			count++
		}
	}
	s.Logger.Info("Created %d new athletes", count)
	return count, nil
}

// insertAthleteIfNotExists inserts an athlete if they don't already exist, including nickname
func (s *SyncEmailService) insertAthleteIfNotExists(ctx context.Context, tx *sql.Tx, parsedAthlete ParsedAthlete) (bool, error) {
	fullName := parsedAthlete.Name

	// Check if athlete already exists
	existingID, err := s.DB.CheckAthleteExists(ctx, tx, fullName)
	if err == nil && existingID > 0 {
		// Athlete exists, skip
		return false, nil
	} else if err != nil && err != sql.ErrNoRows {
		return false, fmt.Errorf("failed to check athlete existence: %w", err)
	}

	// Create new athlete
	athleteID, err := s.DB.InsertAthlete(ctx, tx, fullName, "", true, "")
	if err != nil {
		return false, fmt.Errorf("failed to insert athlete %s: %w", fullName, err)
	}
	s.Logger.Debug("Created new athlete: %s (ID: %d)", fullName, athleteID)

	return true, nil
}
