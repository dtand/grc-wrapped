package models

type WorkoutGroup struct {
	ID          int              `db:"id" json:"id"`
	WorkoutID   int              `db:"workout_id" json:"workout_id"`
	GroupName   string           `db:"group_name" json:"group_name"`
	Description string           `db:"description" json:"description,omitempty"`
	Segments    []WorkoutSegment `json:"segments,omitempty"`
}
