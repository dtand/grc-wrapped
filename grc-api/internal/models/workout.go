package models

import "database/sql"

type Workout struct {
	ID         int            `db:"id" json:"id"`
	Date       string         `db:"date" json:"date"`
	Location   sql.NullString `db:"location" json:"location,omitempty"`
	StartTime  sql.NullString `db:"start_time" json:"start_time,omitempty"`
	CoachNotes sql.NullString `db:"coach_notes" json:"coach_notes,omitempty"`
	EmailID    int            `db:"email_id" json:"email_id"`
	Groups     []WorkoutGroup `json:"groups,omitempty"`
}
