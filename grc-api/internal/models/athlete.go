package models

import (
	"database/sql"
	"encoding/json"
)

type Athlete struct {
	ID         int            `db:"id" json:"id"`
	Name       string         `db:"name" json:"name"`
	Gender     sql.NullString `db:"gender" json:"-"`
	Active     bool           `db:"active" json:"active"`
	WebsiteURL string         `db:"website_url" json:"website_url"`
}

// MarshalJSON custom marshaler to handle gender field properly
func (a Athlete) MarshalJSON() ([]byte, error) {
	gender := ""
	if a.Gender.Valid {
		gender = a.Gender.String
	}

	return json.Marshal(struct {
		ID         int    `json:"id"`
		Name       string `json:"name"`
		Gender     string `json:"gender"`
		Active     bool   `json:"active"`
		WebsiteURL string `json:"website_url"`
	}{
		ID:         a.ID,
		Name:       a.Name,
		Gender:     gender,
		Active:     a.Active,
		WebsiteURL: a.WebsiteURL,
	})
}
