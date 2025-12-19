package models

type YearlyStats struct {
	PersonalBests       int                      `json:"personal_bests"`
	RacesCompeted       int                      `json:"races_competed"`
	ClubRecords         PerformanceList          `json:"club_records"`
	PopularRaces        []PopularRaceEntry       `json:"popular_races"`
	DistanceBreakdown   []DistanceBreakdownEntry `json:"distance_breakdown"`
	TopListPerformances PerformanceList          `json:"top_list_performances"`
	RacesWon            int                      `json:"races_won"`
	GRCDebuts           []DebutEntry             `json:"grc_debuts"`
}

type PerformanceList struct {
	Count        int                 `json:"count"`
	Performances []PerformanceDetail `json:"performances"`
}

type PerformanceDetail struct {
	AthleteID    int    `json:"athlete_id"`
	AthleteName  string `json:"athlete_name"`
	RaceDistance string `json:"race_distance"`
	Time         string `json:"time"`
}

type DistanceBreakdownEntry struct {
	Distance   string `json:"distance"`
	TotalRaces int    `json:"total_races"`
}

type DebutEntry struct {
	AthleteName string `json:"athlete_name"`
}
