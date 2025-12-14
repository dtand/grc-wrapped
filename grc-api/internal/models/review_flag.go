package models

import (
	"database/sql"
	"time"
)

// ReviewFlag represents a flag for items needing review
type ReviewFlag struct {
	ID               int            `db:"id"`
	FlagType         string         `db:"flag_type"`
	EntityType       string         `db:"entity_type"`
	EntityID         int            `db:"entity_id"`
	Reason           string         `db:"reason"`
	MentionedName    string         `db:"mentioned_name"`
	MatchedAthleteID sql.NullInt64  `db:"matched_athlete_id"`
	Resolved         bool           `db:"resolved"`
	ResolvedBy       sql.NullString `db:"resolved_by"`
	ResolvedAt       sql.NullTime   `db:"resolved_at"`
	EmailID          int            `db:"email_id"`
	CreatedAt        time.Time      `db:"created_at"`
}
