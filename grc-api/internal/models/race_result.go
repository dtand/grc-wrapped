package models

import "database/sql"

type RaceResult struct {
	ID                 int            `db:"id" json:"id"`
	RaceID             int            `db:"race_id" json:"race_id"`
	AthleteID          *int           `db:"athlete_id" json:"athlete_id,omitempty"`
	UnknownAthleteName string         `db:"unknown_athlete_name" json:"unknown_athlete_name,omitempty"`
	Time               string         `db:"time" json:"time"`
	PRImprovement      sql.NullString `db:"pr_improvement" json:"pr_improvement,omitempty"`
	Notes              sql.NullString `db:"notes" json:"notes,omitempty"`
	Position           *int           `db:"position" json:"position,omitempty"`
	IsPR               bool           `db:"is_pr" json:"is_pr"`
	IsClubRecord       bool           `db:"is_club_record" json:"is_club_record"`
	Tags               []string       `db:"tags" json:"tags,omitempty"`
	Flagged            bool           `db:"flagged" json:"flagged"`
	FlagReason         sql.NullString `db:"flag_reason" json:"flag_reason,omitempty"`
	EmailID            int            `db:"email_id" json:"email_id"`
	DateRecorded       sql.NullString `db:"date_recorded" json:"date_recorded,omitempty"`
}
