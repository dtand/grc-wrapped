// race_result_processor.go handles race result creation with athlete matching
package service

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
)

// processRaceResults handles race result creation with athlete matching and flagging
func (s *SyncEmailService) processRaceResults(ctx context.Context, tx *sql.Tx, raceResults []ParsedRaceResult, raceNameToID map[string]int, emailID int) (int, error) {
	if len(raceResults) == 0 {
		return 0, nil
	}

	s.Logger.Info("Processing %d race results", len(raceResults))
	count := 0
	skipped := 0
	flaggedCount := 0

	for _, parsedResult := range raceResults {
		// Match or flag athlete
		athleteID, flagged, flagReason, err := s.matchOrFlagAthlete(ctx, tx, parsedResult.AthleteName)
		if err != nil {
			return 0, err
		}

		// Match race name to race_id
		raceID, raceExists := raceNameToID[parsedResult.RaceName]
		if !raceExists {
			s.Logger.Debug("Race not found for result: '%s' - skipping", parsedResult.RaceName)
			skipped++
			continue // Skip this result
		}

		// Handle nullable position
		var positionVal sql.NullInt64
		if parsedResult.Position != nil {
			positionVal = sql.NullInt64{Int64: int64(*parsedResult.Position), Valid: true}
		}

		// Prepare athlete ID and unknown name
		var athleteIDNull sql.NullInt64
		var unknownName string
		if athleteID == 0 {
			athleteIDNull = sql.NullInt64{Valid: false}
			unknownName = parsedResult.AthleteName
		} else {
			athleteIDNull = sql.NullInt64{Int64: int64(athleteID), Valid: true}
			unknownName = ""
		}

		// Insert race result with actual_distance (will be populated by migration script)
		actualDistance := ""
		raceResultID, err := s.DB.InsertRaceResult(
			ctx, tx, raceID, athleteIDNull, unknownName, parsedResult.Time, positionVal,
			parsedResult.IsPR, parsedResult.Notes, parsedResult.Tags, flagged, flagReason, emailID, actualDistance,
		)
		if err != nil {
			return 0, err
		}
		count++

		// Create review flag if flagged
		if flagged {
			flagType := "unknown_athlete"

			if err := s.DB.InsertReviewFlag(ctx, tx, flagType, "race_result", raceResultID, flagReason, parsedResult.AthleteName, sql.NullInt64{Valid: false}, emailID); err != nil {
				s.Logger.Warn("Warning: failed to insert review flag: %v", err)
			} else {
				flaggedCount++
			}
		}
	}

	s.Logger.Info("Created %d race results (%d skipped for missing races, %d flagged for unknown athletes)", count, skipped, flaggedCount)
	return count, nil
}

// matchOrFlagAthlete attempts to match an athlete name, inserting new ones for full names or flagging unknowns
func (s *SyncEmailService) matchOrFlagAthlete(ctx context.Context, tx *sql.Tx, athleteName string) (int, bool, string, error) {
	// Attempt to match athlete
	athlete, err := s.AthleteMatcher.MatchAthleteName(ctx, athleteName)
	if err != nil {
		// Check if name has both first and last (contains space) - if so, insert as new athlete
		if strings.Contains(athleteName, " ") {
			// Insert new athlete with active=false
			athleteID, insertErr := s.DB.InsertAthlete(ctx, tx, athleteName, "", false, "")
			if insertErr != nil {
				s.Logger.Warn("Failed to insert new athlete '%s': %v - flagging instead", athleteName, insertErr)
				return 0, true, fmt.Sprintf("unknown athlete: %s", athleteName), nil
			} else {
				s.Logger.Debug("Inserted new athlete '%s' with active=false (ID: %d)", athleteName, athleteID)
				// Return the athlete ID directly since we just inserted it
				return athleteID, false, "", nil
			}
		} else {
			// First name only - flag as unknown
			s.Logger.Debug("Failed to match athlete '%s' (first name only): %v - flagging", athleteName, err)
			return 0, true, fmt.Sprintf("unknown athlete: %s", athleteName), nil
		}
	} else {
		return athlete.ID, false, "", nil
	}
}
