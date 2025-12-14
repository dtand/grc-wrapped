package models

// AthleteNickname represents a nickname/alias for an athlete
type AthleteNickname struct {
	ID        int    `db:"id"`
	AthleteID int    `db:"athlete_id"`
	Nickname  string `db:"nickname"`
}
