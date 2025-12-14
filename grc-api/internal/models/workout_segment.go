package models

type WorkoutSegment struct {
	ID              int    `db:"id" json:"id"`
	WorkoutGroupID  int    `db:"workout_group_id" json:"workout_group_id"`
	SegmentType     string `db:"segment_type" json:"segment_type"`
	Repetitions     int    `db:"repetitions" json:"repetitions"`
	Rest            string `db:"rest" json:"rest"`
	Targets         string `db:"targets" json:"targets"`
}
