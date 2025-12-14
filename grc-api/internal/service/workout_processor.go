// workout_processor.go handles workout, group, and segment creation
package service

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"strings"
)

// processWorkouts handles workout, group, and segment creation
func (s *SyncEmailService) processWorkouts(ctx context.Context, tx *sql.Tx, workouts []ParsedWorkout, emailID int) (int, error) {
	if len(workouts) == 0 {
		return 0, nil
	}

	log.Printf("Processing %d workouts", len(workouts))
	count := 0
	totalGroups := 0
	totalSegments := 0

	for _, parsedWorkout := range workouts {
		// Insert workout
		workoutID, err := s.DB.InsertWorkout(ctx, tx, parsedWorkout.Date, parsedWorkout.Location, parsedWorkout.Description, emailID)
		if err != nil {
			return 0, err
		}
		count++

		// Process workout groups
		for _, group := range parsedWorkout.Groups {
			workoutGroupID, err := s.DB.InsertWorkoutGroup(ctx, tx, workoutID, group.GroupName, "")
			if err != nil {
				return 0, fmt.Errorf("failed to insert workout group: %w", err)
			}
			totalGroups++

			// Process workout segments
			for _, segment := range group.Segments {
				segmentType := strings.TrimSpace(segment.Description)
				if segmentType == "" {
					// Provide a default description based on available data
					if segment.Distance != "" && segment.Reps > 0 {
						segmentType = fmt.Sprintf("%dx %s", segment.Reps, segment.Distance)
					} else if segment.Distance != "" {
						segmentType = segment.Distance
					} else if segment.Reps > 0 {
						segmentType = fmt.Sprintf("%d reps", segment.Reps)
					} else {
						segmentType = "Workout segment"
					}
				}

				targets := fmt.Sprintf("Distance: %s, Pace: %s", segment.Distance, segment.TargetPace)
				if err := s.DB.InsertWorkoutSegment(ctx, tx, workoutGroupID, segmentType, segment.Reps, segment.RestTime, targets); err != nil {
					return 0, fmt.Errorf("failed to insert workout segment: %w", err)
				}
				totalSegments++
			}
		}
	}

	log.Printf("Created %d workouts with %d groups and %d segments", count, totalGroups, totalSegments)
	return count, nil
}
