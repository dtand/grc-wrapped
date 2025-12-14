package models

import "database/sql"

type Race struct {
	ID       int            `db:"id" json:"id"`
	Name     string         `db:"name" json:"name"`
	Date     sql.NullString `db:"date" json:"date"`
	Year     int            `db:"year" json:"year"`
	Distance string         `db:"distance" json:"distance"`
	Type     string         `db:"type" json:"type"`
	Notes    sql.NullString `db:"notes" json:"notes"`
	EmailID  int            `db:"email_id" json:"email_id"`
}
