package models

type YearlyStats struct {
	PersonalBests int                `json:"personal_bests"`
	RacesCompeted int                `json:"races_competed"`
	ClubRecords   int                `json:"club_records"`
	PopularRaces  []PopularRaceEntry `json:"popular_races"`
}
