package db

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/grcwrapped/grcapi/config"
	"github.com/grcwrapped/grcapi/internal/models"

	_ "github.com/lib/pq"

	"github.com/lib/pq"
)

// DB wraps the sql.DB connection and provides methods for database access
// You can extend this struct with helper methods as needed

type DB struct {
	*sql.DB
}

// NewDB creates a new database connection using the provided config
func NewDB(cfg *config.Config) (*DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		cfg.DBHost,
		cfg.DBPort,
		cfg.DBUser,
		cfg.DBPassword,
		cfg.DBName,
	)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open db: %w", err)
	}
	// Optionally, ping to verify connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping db: %w", err)
	}
	return &DB{db}, nil
}

// Close closes the database connection
func (db *DB) Close() error {
	return db.DB.Close()
}

// InsertEmail inserts an email and returns its ID
func (db *DB) InsertEmail(ctx context.Context, tx *sql.Tx, title, body, date, sender, recipient string) (int, error) {
	// Normalize title for consistent deduplication
	normalizedTitle := strings.TrimSpace(strings.ToLower(title))

	var emailID int
	query := `
		INSERT INTO emails (title, body, date, sender, recipient)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`
	err := tx.QueryRowContext(ctx, query, normalizedTitle, body, date, sender, recipient).Scan(&emailID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert email: %w", err)
	}
	return emailID, nil
}

// CheckEmailExists checks if an email already exists by title and date
func (db *DB) CheckEmailExists(ctx context.Context, title, date string) (bool, error) {
	// Normalize title for consistent checking
	normalizedTitle := strings.TrimSpace(strings.ToLower(title))

	var exists bool
	query := `SELECT EXISTS(SELECT 1 FROM emails WHERE title = $1 AND date = $2)`
	err := db.QueryRowContext(ctx, query, normalizedTitle, date).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to check email existence: %w", err)
	}
	return exists, nil
}

// GetEmails retrieves emails with optional filtering and pagination
func (db *DB) GetEmails(ctx context.Context, title, sender, recipient, date string, limit, offset int) ([]*models.Email, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if title != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("title ILIKE $%d", argCount))
		args = append(args, "%"+title+"%")
	}
	if sender != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("sender ILIKE $%d", argCount))
		args = append(args, "%"+sender+"%")
	}
	if recipient != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("recipient ILIKE $%d", argCount))
		args = append(args, "%"+recipient+"%")
	}
	if date != "" {
		// Support date ranges like ">=2025-01-01" or exact dates
		if strings.HasPrefix(date, ">=") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date >= $%d", argCount))
			args = append(args, strings.TrimPrefix(date, ">="))
		} else if strings.HasPrefix(date, "<=") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date <= $%d", argCount))
			args = append(args, strings.TrimPrefix(date, "<="))
		} else if strings.HasPrefix(date, ">") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date > $%d", argCount))
			args = append(args, strings.TrimPrefix(date, ">"))
		} else if strings.HasPrefix(date, "<") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date < $%d", argCount))
			args = append(args, strings.TrimPrefix(date, "<"))
		} else {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date = $%d", argCount))
			args = append(args, date)
		}
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`
		SELECT id, title, body, date, sender, recipient
		FROM emails
		%s
		ORDER BY date DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argCount+1, argCount+2)
	args = append(args, limit, offset)

	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query emails: %w", err)
	}
	defer rows.Close()

	var emails []*models.Email
	for rows.Next() {
		var email models.Email
		err := rows.Scan(&email.ID, &email.Title, &email.Body, &email.Date, &email.Sender, &email.Recipient)
		if err != nil {
			return nil, fmt.Errorf("failed to scan email: %w", err)
		}
		emails = append(emails, &email)
	}
	return emails, nil
}

// GetEmailsCount returns the total count of emails matching the filters
func (db *DB) GetEmailsCount(ctx context.Context, title, sender, recipient, date string) (int, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if title != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("title ILIKE $%d", argCount))
		args = append(args, "%"+title+"%")
	}
	if sender != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("sender ILIKE $%d", argCount))
		args = append(args, "%"+sender+"%")
	}
	if recipient != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("recipient ILIKE $%d", argCount))
		args = append(args, "%"+recipient+"%")
	}
	if date != "" {
		// Support date ranges like ">=2025-01-01" or exact dates
		if strings.HasPrefix(date, ">=") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date >= $%d", argCount))
			args = append(args, strings.TrimPrefix(date, ">="))
		} else if strings.HasPrefix(date, "<=") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date <= $%d", argCount))
			args = append(args, strings.TrimPrefix(date, "<="))
		} else if strings.HasPrefix(date, ">") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date > $%d", argCount))
			args = append(args, strings.TrimPrefix(date, ">"))
		} else if strings.HasPrefix(date, "<") {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date < $%d", argCount))
			args = append(args, strings.TrimPrefix(date, "<"))
		} else {
			argCount++
			whereClauses = append(whereClauses, fmt.Sprintf("date = $%d", argCount))
			args = append(args, date)
		}
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`SELECT COUNT(*) FROM emails %s`, whereClause)
	var count int
	err := db.QueryRowContext(ctx, query, args...).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count emails: %w", err)
	}
	return count, nil
}

// GetEmailByID retrieves a single email by ID
func (db *DB) GetEmailByID(ctx context.Context, id int) (*models.Email, error) {
	query := `SELECT id, title, body, date, sender, recipient FROM emails WHERE id = $1`
	var email models.Email
	err := db.QueryRowContext(ctx, query, id).Scan(&email.ID, &email.Title, &email.Body, &email.Date, &email.Sender, &email.Recipient)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get email: %w", err)
	}
	return &email, nil
}

// CheckAthleteExists checks if an athlete exists by name and returns their ID
func (db *DB) CheckAthleteExists(ctx context.Context, tx *sql.Tx, name string) (int, error) {
	var athleteID int
	query := `SELECT id FROM athletes WHERE name = $1`
	err := tx.QueryRowContext(ctx, query, name).Scan(&athleteID)
	return athleteID, err
}

// InsertAthlete creates a new athlete record and returns its ID
func (db *DB) InsertAthlete(ctx context.Context, tx *sql.Tx, name, gender string, active bool, websiteURL string) (int, error) {
	// Convert empty gender string to NULL
	var genderValue interface{}
	if gender == "" {
		genderValue = nil
	} else {
		genderValue = gender
	}

	query := `
		INSERT INTO athletes (name, gender, active, website_url)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (name) DO UPDATE SET
			gender = EXCLUDED.gender,
			active = EXCLUDED.active,
			website_url = EXCLUDED.website_url
		RETURNING id
	`
	var athleteID int
	err := tx.QueryRowContext(ctx, query, name, genderValue, active, websiteURL).Scan(&athleteID)
	return athleteID, err
}

// InsertAthleteNickname creates a nickname for an athlete
func (db *DB) InsertAthleteNickname(ctx context.Context, tx *sql.Tx, athleteID int, nickname string) error {
	query := `
		INSERT INTO athlete_nicknames (athlete_id, nickname)
		VALUES ($1, $2)
		ON CONFLICT (athlete_id, nickname) DO NOTHING
	`
	_, err := tx.ExecContext(ctx, query, athleteID, nickname)
	return err
}

// GetAthleteNicknames returns athlete nicknames with optional filtering
func (db *DB) GetAthleteNicknames(ctx context.Context, athleteID *int, nickname string, limit, offset int) ([]*models.AthleteNickname, error) {
	query := `
		SELECT id, athlete_id, nickname
		FROM athlete_nicknames
		WHERE ($1::int IS NULL OR athlete_id = $1)
		AND ($2 = '' OR nickname ILIKE '%' || $2 || '%')
		ORDER BY athlete_id, nickname
		LIMIT $3 OFFSET $4
	`
	rows, err := db.QueryContext(ctx, query, athleteID, nickname, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query athlete nicknames: %w", err)
	}
	defer rows.Close()

	var nicknames []*models.AthleteNickname
	for rows.Next() {
		var nickname models.AthleteNickname
		err := rows.Scan(&nickname.ID, &nickname.AthleteID, &nickname.Nickname)
		if err != nil {
			return nil, fmt.Errorf("failed to scan athlete nickname: %w", err)
		}
		nicknames = append(nicknames, &nickname)
	}
	return nicknames, nil
}

// GetAthleteNicknamesCount returns the total count of athlete nicknames matching the filters
func (db *DB) GetAthleteNicknamesCount(ctx context.Context, athleteID *int, nickname string) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM athlete_nicknames
		WHERE ($1::int IS NULL OR athlete_id = $1)
		AND ($2 = '' OR nickname ILIKE '%' || $2 || '%')
	`
	var count int
	err := db.QueryRowContext(ctx, query, athleteID, nickname).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count athlete nicknames: %w", err)
	}
	return count, nil
}

// GetAthleteNicknameByID returns a single athlete nickname by ID
func (db *DB) GetAthleteNicknameByID(ctx context.Context, id int) (*models.AthleteNickname, error) {
	query := `SELECT id, athlete_id, nickname FROM athlete_nicknames WHERE id = $1`
	var nickname models.AthleteNickname
	err := db.QueryRowContext(ctx, query, id).Scan(&nickname.ID, &nickname.AthleteID, &nickname.Nickname)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get athlete nickname: %w", err)
	}
	return &nickname, nil
}

// InsertAthleteNicknameAPI creates a nickname for an athlete (API version without transaction)
func (db *DB) InsertAthleteNicknameAPI(ctx context.Context, athleteID int, nickname string) error {
	query := `
		INSERT INTO athlete_nicknames (athlete_id, nickname)
		VALUES ($1, $2)
		ON CONFLICT (athlete_id, nickname) DO NOTHING
	`
	_, err := db.ExecContext(ctx, query, athleteID, nickname)
	return err
}

// UpdateAthleteNickname updates an existing athlete nickname
func (db *DB) UpdateAthleteNickname(ctx context.Context, id int, athleteID int, nickname string) error {
	query := `
		UPDATE athlete_nicknames
		SET athlete_id = $2, nickname = $3
		WHERE id = $1
	`
	_, err := db.ExecContext(ctx, query, id, athleteID, nickname)
	if err != nil {
		return fmt.Errorf("failed to update athlete nickname: %w", err)
	}
	return nil
}

// DeleteAthleteNickname removes an athlete nickname from the database
func (db *DB) DeleteAthleteNickname(ctx context.Context, id int) error {
	query := `DELETE FROM athlete_nicknames WHERE id = $1`
	_, err := db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete athlete nickname: %w", err)
	}
	return nil
}

// CheckRaceExists checks if a race exists by name and year, returns its ID
func (db *DB) CheckRaceExists(ctx context.Context, tx *sql.Tx, name string, year int) (int, error) {
	var raceID int
	query := `SELECT id FROM races WHERE name = $1 AND year = $2 LIMIT 1`
	err := tx.QueryRowContext(ctx, query, name, year).Scan(&raceID)
	return raceID, err
}

// InsertRace creates a new race record and returns its ID
func (db *DB) InsertRace(ctx context.Context, tx *sql.Tx, name, date, distance, raceType string, year int, emailID int) (int, error) {
	var raceID int
	var dateParam sql.NullString
	if date != "" {
		dateParam = sql.NullString{String: date, Valid: true}
	}

	query := `
		INSERT INTO races (name, date, year, distance, type, email_id)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`
	err := tx.QueryRowContext(ctx, query, name, dateParam, year, distance, raceType, emailID).Scan(&raceID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert race: %w", err)
	}
	return raceID, nil
}

// InsertRaceResult creates a race result record and returns its ID
func (db *DB) InsertRaceResult(ctx context.Context, tx *sql.Tx, raceID int, athleteID sql.NullInt64, unknownName, time string, position sql.NullInt64, isPR bool, notes string, tags []string, flagged bool, flagReason string, emailID int) (int, error) {
	var raceResultID int
	query := `
		INSERT INTO race_results (
			race_id, athlete_id, unknown_athlete_name, time, position, is_pr, notes, tags, 
			flagged, flag_reason, email_id, date_recorded
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, (SELECT date FROM emails WHERE id = $11))
		RETURNING id
	`
	err := tx.QueryRowContext(
		ctx,
		query,
		raceID,
		athleteID,
		unknownName,
		time,
		position,
		isPR,
		notes,
		pq.Array(tags),
		flagged,
		flagReason,
		emailID,
	).Scan(&raceResultID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert race result: %w", err)
	}
	return raceResultID, nil
}

// InsertReviewFlag creates a review flag for manual verification
func (db *DB) InsertReviewFlag(ctx context.Context, tx *sql.Tx, flagType, entityType string, entityID int, reason, mentionedName string, matchedAthleteID sql.NullInt64, emailID int) error {
	query := `
		INSERT INTO review_flags (
			flag_type, entity_type, entity_id, reason,
			mentioned_name, matched_athlete_id, email_id
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err := tx.ExecContext(ctx, query, flagType, entityType, entityID, reason, mentionedName, matchedAthleteID, emailID)
	return err
}

// GetReviewFlags returns review flags with optional filtering
func (db *DB) GetReviewFlags(ctx context.Context, resolved *bool, flagType, entityType string, emailID *int, limit, offset int) ([]*models.ReviewFlag, error) {
	query := `
		SELECT id, flag_type, entity_type, entity_id, reason, mentioned_name,
		       matched_athlete_id, resolved, resolved_by, resolved_at, email_id, created_at
		FROM review_flags
		WHERE ($1::boolean IS NULL OR resolved = $1)
		AND ($2 = '' OR flag_type = $2)
		AND ($3 = '' OR entity_type = $3)
		AND ($4::int IS NULL OR email_id = $4)
		ORDER BY created_at DESC
		LIMIT $5 OFFSET $6
	`
	rows, err := db.QueryContext(ctx, query, resolved, flagType, entityType, emailID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query review flags: %w", err)
	}
	defer rows.Close()

	var flags []*models.ReviewFlag
	for rows.Next() {
		var flag models.ReviewFlag
		err := rows.Scan(&flag.ID, &flag.FlagType, &flag.EntityType, &flag.EntityID, &flag.Reason,
			&flag.MentionedName, &flag.MatchedAthleteID, &flag.Resolved, &flag.ResolvedBy,
			&flag.ResolvedAt, &flag.EmailID, &flag.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan review flag: %w", err)
		}
		flags = append(flags, &flag)
	}
	return flags, nil
}

// GetReviewFlagsCount returns the total count of review flags matching the filters
func (db *DB) GetReviewFlagsCount(ctx context.Context, resolved *bool, flagType, entityType string, emailID *int) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM review_flags
		WHERE ($1::boolean IS NULL OR resolved = $1)
		AND ($2 = '' OR flag_type = $2)
		AND ($3 = '' OR entity_type = $3)
		AND ($4::int IS NULL OR email_id = $4)
	`
	var count int
	err := db.QueryRowContext(ctx, query, resolved, flagType, entityType, emailID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count review flags: %w", err)
	}
	return count, nil
}

// GetReviewFlagByID returns a single review flag by ID
func (db *DB) GetReviewFlagByID(ctx context.Context, id int) (*models.ReviewFlag, error) {
	query := `
		SELECT id, flag_type, entity_type, entity_id, reason, mentioned_name,
		       matched_athlete_id, resolved, resolved_by, resolved_at, email_id, created_at
		FROM review_flags WHERE id = $1
	`
	var flag models.ReviewFlag
	err := db.QueryRowContext(ctx, query, id).Scan(&flag.ID, &flag.FlagType, &flag.EntityType, &flag.EntityID,
		&flag.Reason, &flag.MentionedName, &flag.MatchedAthleteID, &flag.Resolved, &flag.ResolvedBy,
		&flag.ResolvedAt, &flag.EmailID, &flag.CreatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get review flag: %w", err)
	}
	return &flag, nil
}

// ResolveReviewFlag marks a review flag as resolved
func (db *DB) ResolveReviewFlag(ctx context.Context, id int, resolvedBy string) error {
	query := `
		UPDATE review_flags
		SET resolved = true, resolved_by = $2, resolved_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err := db.ExecContext(ctx, query, id, resolvedBy)
	if err != nil {
		return fmt.Errorf("failed to resolve review flag: %w", err)
	}
	return nil
}

// InsertWorkout creates a workout record and returns its ID
func (db *DB) InsertWorkout(ctx context.Context, tx *sql.Tx, date, location, coachNotes string, emailID int) (int, error) {
	var workoutID int
	query := `
		INSERT INTO workouts (date, location, coach_notes, email_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id
	`
	err := tx.QueryRowContext(ctx, query, date, location, coachNotes, emailID).Scan(&workoutID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert workout: %w", err)
	}
	return workoutID, nil
}

// InsertWorkoutGroup creates a workout group and returns its ID
func (db *DB) InsertWorkoutGroup(ctx context.Context, tx *sql.Tx, workoutID int, groupName, description string) (int, error) {
	var workoutGroupID int
	query := `
		INSERT INTO workout_groups (workout_id, group_name, description)
		VALUES ($1, $2, $3)
		RETURNING id
	`
	err := tx.QueryRowContext(ctx, query, workoutID, groupName, description).Scan(&workoutGroupID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert workout group: %w", err)
	}
	return workoutGroupID, nil
}

// InsertWorkoutSegment creates a workout segment
func (db *DB) InsertWorkoutSegment(ctx context.Context, tx *sql.Tx, workoutGroupID int, segmentType string, repetitions int, rest, targets string) error {
	query := `
		INSERT INTO workout_segments (
			workout_group_id, segment_type, repetitions, rest, targets
		)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := tx.ExecContext(ctx, query, workoutGroupID, segmentType, repetitions, rest, targets)
	return err
}

// GetAthletes retrieves athletes with optional filtering and pagination
func (db *DB) GetAthletes(ctx context.Context, name, gender string, active *bool, limit, offset int) ([]*models.Athlete, error) {
	query := `
		SELECT id, name, gender, active, website_url
		FROM athletes
		WHERE ($1 = '' OR name ILIKE '%' || $1 || '%')
		AND ($2 = '' OR gender = $2)
		AND ($3::boolean IS NULL OR active = $3)
		ORDER BY name
		LIMIT $4 OFFSET $5
	`
	rows, err := db.QueryContext(ctx, query, name, gender, active, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query athletes: %w", err)
	}
	defer rows.Close()

	var athletes []*models.Athlete
	for rows.Next() {
		var athlete models.Athlete
		err := rows.Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
		if err != nil {
			return nil, fmt.Errorf("failed to scan athlete: %w", err)
		}
		athletes = append(athletes, &athlete)
	}
	return athletes, nil
}

// GetAthletesCount returns the total count of athletes matching the filters
func (db *DB) GetAthletesCount(ctx context.Context, name, gender string, active *bool) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM athletes
		WHERE ($1 = '' OR name ILIKE '%' || $1 || '%')
		AND ($2 = '' OR gender = $2)
		AND ($3::boolean IS NULL OR active = $3)
	`
	var count int
	err := db.QueryRowContext(ctx, query, name, gender, active).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count athletes: %w", err)
	}
	return count, nil
}

// GetAthleteByID retrieves a single athlete by ID
func (db *DB) GetAthleteByID(ctx context.Context, id int) (*models.Athlete, error) {
	query := `SELECT id, name, gender, active, website_url FROM athletes WHERE id = $1`
	var athlete models.Athlete
	err := db.QueryRowContext(ctx, query, id).Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get athlete: %w", err)
	}
	return &athlete, nil
}

// UpdateAthlete updates an existing athlete
func (db *DB) UpdateAthlete(ctx context.Context, id int, name, gender string, active bool, websiteURL string) error {
	// Convert empty gender string to NULL
	var genderValue interface{}
	if gender == "" {
		genderValue = nil
	} else {
		genderValue = gender
	}

	query := `
		UPDATE athletes
		SET name = $2, gender = $3, active = $4, website_url = $5
		WHERE id = $1
	`
	_, err := db.ExecContext(ctx, query, id, name, genderValue, active, websiteURL)
	if err != nil {
		return fmt.Errorf("failed to update athlete: %w", err)
	}
	return nil
}

// DeleteAthlete removes an athlete from the database
func (db *DB) DeleteAthlete(ctx context.Context, id int) error {
	query := `DELETE FROM athletes WHERE id = $1`
	_, err := db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete athlete: %w", err)
	}
	return nil
}

// InsertRaceAPI creates a new race in the database (API version without transaction)
func (db *DB) InsertRaceAPI(ctx context.Context, name string, date sql.NullString, distance string, raceType string, notes sql.NullString, year int, emailID int) (int, error) {
	query := `
		INSERT INTO races (name, date, year, distance, type, notes, email_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id
	`
	var id int
	err := db.QueryRowContext(ctx, query, name, date, year, distance, raceType, notes, emailID).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("failed to insert race: %w", err)
	}
	return id, nil
}

// GetRaces retrieves races with optional filtering and pagination
func (db *DB) GetRaces(ctx context.Context, name, year, distance string, emailID *int, limit, offset int) ([]*models.Race, error) {
	query := `
		SELECT id, name, date, year, distance, type, notes, email_id
		FROM races
		WHERE ($1 = '' OR name ILIKE '%' || $1 || '%')
		AND ($2 = '' OR year::text = $2)
		AND ($3 = '' OR distance ILIKE '%' || $3 || '%')
		AND ($4::integer IS NULL OR email_id = $4)
		ORDER BY year DESC, name
		LIMIT $5 OFFSET $6
	`
	rows, err := db.QueryContext(ctx, query, name, year, distance, emailID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query races: %w", err)
	}
	defer rows.Close()

	var races []*models.Race
	for rows.Next() {
		var race models.Race
		err := rows.Scan(&race.ID, &race.Name, &race.Date, &race.Year, &race.Distance, &race.Type, &race.Notes, &race.EmailID)
		if err != nil {
			return nil, fmt.Errorf("failed to scan race: %w", err)
		}
		races = append(races, &race)
	}
	return races, nil
}

// GetRacesCount returns the total count of races matching the filters
func (db *DB) GetRacesCount(ctx context.Context, name, year, distance string, emailID *int) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM races
		WHERE ($1 = '' OR name ILIKE '%' || $1 || '%')
		AND ($2 = '' OR year::text = $2)
		AND ($3 = '' OR distance ILIKE '%' || $3 || '%')
		AND ($4::integer IS NULL OR email_id = $4)
	`
	var count int
	err := db.QueryRowContext(ctx, query, name, year, distance, emailID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count races: %w", err)
	}
	return count, nil
}

// GetRaceByID retrieves a single race by ID
func (db *DB) GetRaceByID(ctx context.Context, id int) (*models.Race, error) {
	query := `SELECT id, name, date, year, distance, type, notes, email_id FROM races WHERE id = $1`
	var race models.Race
	err := db.QueryRowContext(ctx, query, id).Scan(&race.ID, &race.Name, &race.Date, &race.Year, &race.Distance, &race.Type, &race.Notes, &race.EmailID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get race: %w", err)
	}
	return &race, nil
}

// UpdateRace updates an existing race
func (db *DB) UpdateRace(ctx context.Context, id int, name string, date sql.NullString, distance string, raceType string, notes sql.NullString, year int, emailID int) error {
	query := `
		UPDATE races
		SET name = $2, date = $3, year = $4, distance = $5, type = $6, notes = $7, email_id = $8
		WHERE id = $1
	`
	_, err := db.ExecContext(ctx, query, id, name, date, year, distance, raceType, notes, emailID)
	if err != nil {
		return fmt.Errorf("failed to update race: %w", err)
	}
	return nil
}

// DeleteRace removes a race from the database
func (db *DB) DeleteRace(ctx context.Context, id int) error {
	query := `DELETE FROM races WHERE id = $1`
	_, err := db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete race: %w", err)
	}
	return nil
}

// InsertRaceResultAPI creates a new race result in the database (API version without transaction)
func (db *DB) InsertRaceResultAPI(ctx context.Context, raceID int, athleteID *int, unknownAthleteName, time string, prImprovement, notes sql.NullString, position *int, isPR bool, isClubRecord bool, tags []string, flagged bool, flagReason sql.NullString, emailID int) (int, error) {
	query := `
	       INSERT INTO race_results (race_id, athlete_id, unknown_athlete_name, time, pr_improvement, notes, position, is_pr, is_club_record, tags, flagged, flag_reason, email_id, date_recorded)
	       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, (SELECT date FROM emails WHERE id = $13))
	       RETURNING id
       `
	var id int
	err := db.QueryRowContext(ctx, query, raceID, athleteID, unknownAthleteName, time, prImprovement, notes, position, isPR, isClubRecord, pq.Array(tags), flagged, flagReason, emailID).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("failed to insert race result: %w", err)
	}
	return id, nil
}

// GetRaceResults retrieves race results with optional filtering and pagination
func (db *DB) GetRaceResults(ctx context.Context, athleteID, raceID *int, isPR *bool, isClubRecord *bool, tags []string, position *int, flagged *bool, emailID *int, dateRecorded, dateRecordedFrom, dateRecordedTo *string, limit, offset int) ([]*models.RaceResult, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if athleteID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("athlete_id = $%d", argCount))
		args = append(args, *athleteID)
	}
	if raceID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("race_id = $%d", argCount))
		args = append(args, *raceID)
	}
	if isPR != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("is_pr = $%d", argCount))
		args = append(args, *isPR)
	}
	if isClubRecord != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("is_club_record = $%d", argCount))
		args = append(args, *isClubRecord)
	}
	if len(tags) > 0 {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("$%d <@ tags", argCount))
		args = append(args, pq.Array(tags))
	}
	if position != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("position = $%d", argCount))
		args = append(args, *position)
	}
	if flagged != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("flagged = $%d", argCount))
		args = append(args, *flagged)
	}
	if emailID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("email_id = $%d", argCount))
		args = append(args, *emailID)
	}
	if dateRecorded != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded = $%d", argCount))
		args = append(args, *dateRecorded)
	}
	if dateRecordedFrom != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded >= $%d", argCount))
		args = append(args, *dateRecordedFrom)
	}
	if dateRecordedTo != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded <= $%d", argCount))
		args = append(args, *dateRecordedTo)
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`
		       SELECT id, race_id, athlete_id, unknown_athlete_name, time, pr_improvement, notes, position, is_pr, is_club_record, tags, flagged, flag_reason, email_id, date_recorded
		       FROM race_results
		       %s
		       ORDER BY id
		       LIMIT $%d OFFSET $%d
	       `, whereClause, argCount+1, argCount+2)
	args = append(args, limit, offset)

	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query race results: %w", err)
	}
	defer rows.Close()

	var raceResults []*models.RaceResult
	for rows.Next() {
		var rr models.RaceResult
		var tags pq.StringArray
		err := rows.Scan(&rr.ID, &rr.RaceID, &rr.AthleteID, &rr.UnknownAthleteName, &rr.Time, &rr.PRImprovement, &rr.Notes, &rr.Position, &rr.IsPR, &rr.IsClubRecord, &tags, &rr.Flagged, &rr.FlagReason, &rr.EmailID, &rr.DateRecorded)
		if err != nil {
			return nil, fmt.Errorf("failed to scan race result: %w", err)
		}
		rr.Tags = []string(tags)
		raceResults = append(raceResults, &rr)
	}
	return raceResults, nil
}

// GetRaceResultsCount returns the total count of race results matching the filters
func (db *DB) GetRaceResultsCount(ctx context.Context, athleteID, raceID *int, isPR *bool, isClubRecord *bool, tags []string, position *int, flagged *bool, emailID *int, dateRecorded, dateRecordedFrom, dateRecordedTo *string) (int, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if athleteID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("athlete_id = $%d", argCount))
		args = append(args, *athleteID)
	}
	if raceID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("race_id = $%d", argCount))
		args = append(args, *raceID)
	}
	if isPR != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("is_pr = $%d", argCount))
		args = append(args, *isPR)
	}
	if isClubRecord != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("is_club_record = $%d", argCount))
		args = append(args, *isClubRecord)
	}
	if len(tags) > 0 {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("$%d <@ tags", argCount))
		args = append(args, pq.Array(tags))
	}
	if position != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("position = $%d", argCount))
		args = append(args, *position)
	}
	if flagged != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("flagged = $%d", argCount))
		args = append(args, *flagged)
	}
	if emailID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("email_id = $%d", argCount))
		args = append(args, *emailID)
	}
	if dateRecorded != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded = $%d", argCount))
		args = append(args, *dateRecorded)
	}
	if dateRecordedFrom != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded >= $%d", argCount))
		args = append(args, *dateRecordedFrom)
	}
	if dateRecordedTo != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date_recorded <= $%d", argCount))
		args = append(args, *dateRecordedTo)
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`SELECT COUNT(*) FROM race_results %s`, whereClause)
	var count int
	err := db.QueryRowContext(ctx, query, args...).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count race results: %w", err)
	}
	return count, nil
}

// GetRaceResultByID retrieves a single race result by ID
func (db *DB) GetRaceResultByID(ctx context.Context, id int) (*models.RaceResult, error) {
	query := `SELECT id, race_id, athlete_id, unknown_athlete_name, time, pr_improvement, notes, position, is_pr, is_club_record, tags, flagged, flag_reason, email_id, date_recorded FROM race_results WHERE id = $1`
	var rr models.RaceResult
	var tags pq.StringArray
	err := db.QueryRowContext(ctx, query, id).Scan(&rr.ID, &rr.RaceID, &rr.AthleteID, &rr.UnknownAthleteName, &rr.Time, &rr.PRImprovement, &rr.Notes, &rr.Position, &rr.IsPR, &rr.IsClubRecord, &tags, &rr.Flagged, &rr.FlagReason, &rr.EmailID, &rr.DateRecorded)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get race result: %w", err)
	}
	rr.Tags = []string(tags)
	return &rr, nil
}

// UpdateRaceResult updates an existing race result
func (db *DB) UpdateRaceResult(ctx context.Context, id, raceID int, athleteID *int, unknownAthleteName, time string, prImprovement, notes sql.NullString, position *int, isPR bool, isClubRecord bool, tags []string, flagged bool, flagReason sql.NullString, emailID int) error {
	query := `
	       UPDATE race_results
	       SET race_id = $2, athlete_id = $3, unknown_athlete_name = $4, time = $5, pr_improvement = $6, notes = $7, position = $8, is_pr = $9, is_club_record = $10, tags = $11, flagged = $12, flag_reason = $13, email_id = $14, date_recorded = (SELECT date FROM emails WHERE id = $14)
	       WHERE id = $1
       `
	_, err := db.ExecContext(ctx, query, id, raceID, athleteID, unknownAthleteName, time, prImprovement, notes, position, isPR, isClubRecord, pq.Array(tags), flagged, flagReason, emailID)
	if err != nil {
		return fmt.Errorf("failed to update race result: %w", err)
	}
	return nil
}

// DeleteRaceResult removes a race result from the database
func (db *DB) DeleteRaceResult(ctx context.Context, id int) error {
	query := `DELETE FROM race_results WHERE id = $1`
	_, err := db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete race result: %w", err)
	}
	return nil
}

// InsertWorkoutAPI creates a new workout with groups and segments in the database (API version without transaction)
func (db *DB) InsertWorkoutAPI(ctx context.Context, date, location, startTime, coachNotes string, emailID int, groups []models.WorkoutGroup) (int, error) {
	var startTimeParam interface{}
	if startTime == "" {
		startTimeParam = nil
	} else {
		startTimeParam = startTime
	}

	query := `
		INSERT INTO workouts (date, location, start_time, coach_notes, email_id)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`
	var id int
	err := db.QueryRowContext(ctx, query, date, location, startTimeParam, coachNotes, emailID).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("failed to insert workout: %w", err)
	}

	// Insert groups and segments
	for _, group := range groups {
		groupID, err := db.InsertWorkoutGroupAPI(ctx, id, group.GroupName, group.Description)
		if err != nil {
			return 0, fmt.Errorf("failed to insert workout group: %w", err)
		}

		for _, segment := range group.Segments {
			err = db.InsertWorkoutSegmentAPI(ctx, groupID, segment.SegmentType, segment.Repetitions, segment.Rest, segment.Targets)
			if err != nil {
				return 0, fmt.Errorf("failed to insert workout segment: %w", err)
			}
		}
	}

	return id, nil
}

// InsertWorkoutGroupAPI creates a new workout group in the database (API version without transaction)
func (db *DB) InsertWorkoutGroupAPI(ctx context.Context, workoutID int, groupName, description string) (int, error) {
	query := `
		INSERT INTO workout_groups (workout_id, group_name, description)
		VALUES ($1, $2, $3)
		RETURNING id
	`
	var id int
	err := db.QueryRowContext(ctx, query, workoutID, groupName, description).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("failed to insert workout group: %w", err)
	}
	return id, nil
}

// InsertWorkoutSegmentAPI creates a new workout segment in the database (API version without transaction)
func (db *DB) InsertWorkoutSegmentAPI(ctx context.Context, workoutGroupID int, segmentType string, repetitions int, rest, targets string) error {
	query := `
		INSERT INTO workout_segments (workout_group_id, segment_type, repetitions, rest, targets)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := db.ExecContext(ctx, query, workoutGroupID, segmentType, repetitions, rest, targets)
	if err != nil {
		return fmt.Errorf("failed to insert workout segment: %w", err)
	}
	return nil
}

// GetWorkouts retrieves workouts with optional filtering and pagination
func (db *DB) GetWorkouts(ctx context.Context, date, location string, emailID *int, limit, offset int) ([]*models.Workout, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if date != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date = $%d", argCount))
		args = append(args, date)
	}
	if location != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("location ILIKE '%%' || $%d || '%%'", argCount))
		args = append(args, location)
	}
	if emailID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("email_id = $%d", argCount))
		args = append(args, *emailID)
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`
		SELECT id, date, location, start_time, coach_notes, email_id
		FROM workouts
		%s
		ORDER BY date DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argCount+1, argCount+2)
	args = append(args, limit, offset)

	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query workouts: %w", err)
	}
	defer rows.Close()

	var workouts []*models.Workout
	for rows.Next() {
		var w models.Workout
		err := rows.Scan(&w.ID, &w.Date, &w.Location, &w.StartTime, &w.CoachNotes, &w.EmailID)
		if err != nil {
			return nil, fmt.Errorf("failed to scan workout: %w", err)
		}
		workouts = append(workouts, &w)
	}
	return workouts, nil
}

// GetWorkoutsCount returns the total count of workouts matching the filters
func (db *DB) GetWorkoutsCount(ctx context.Context, date, location string, emailID *int) (int, error) {
	whereClauses := []string{}
	args := []interface{}{}
	argCount := 0

	if date != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("date = $%d", argCount))
		args = append(args, date)
	}
	if location != "" {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("location ILIKE '%%' || $%d || '%%'", argCount))
		args = append(args, location)
	}
	if emailID != nil {
		argCount++
		whereClauses = append(whereClauses, fmt.Sprintf("email_id = $%d", argCount))
		args = append(args, *emailID)
	}

	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = "WHERE " + strings.Join(whereClauses, " AND ")
	}

	query := fmt.Sprintf(`SELECT COUNT(*) FROM workouts %s`, whereClause)
	var count int
	err := db.QueryRowContext(ctx, query, args...).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count workouts: %w", err)
	}
	return count, nil
}

// GetWorkoutByID retrieves a single workout by ID with all groups and segments
func (db *DB) GetWorkoutByID(ctx context.Context, id int) (*models.Workout, error) {
	// Get the workout
	query := `SELECT id, date, location, start_time, coach_notes, email_id FROM workouts WHERE id = $1`
	var w models.Workout
	err := db.QueryRowContext(ctx, query, id).Scan(&w.ID, &w.Date, &w.Location, &w.StartTime, &w.CoachNotes, &w.EmailID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get workout: %w", err)
	}

	// Get the groups for this workout
	groups, err := db.GetWorkoutGroupsByWorkoutID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get workout groups: %w", err)
	}

	w.Groups = groups
	return &w, nil
}

// GetWorkoutGroupsByWorkoutID retrieves all groups for a workout with their segments
func (db *DB) GetWorkoutGroupsByWorkoutID(ctx context.Context, workoutID int) ([]models.WorkoutGroup, error) {
	query := `SELECT id, workout_id, group_name, description FROM workout_groups WHERE workout_id = $1 ORDER BY id`
	rows, err := db.QueryContext(ctx, query, workoutID)
	if err != nil {
		return nil, fmt.Errorf("failed to query workout groups: %w", err)
	}
	defer rows.Close()

	var groups []models.WorkoutGroup
	for rows.Next() {
		var g models.WorkoutGroup
		err := rows.Scan(&g.ID, &g.WorkoutID, &g.GroupName, &g.Description)
		if err != nil {
			return nil, fmt.Errorf("failed to scan workout group: %w", err)
		}

		// Get segments for this group
		segments, err := db.GetWorkoutSegmentsByGroupID(ctx, g.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get workout segments: %w", err)
		}

		g.Segments = segments
		groups = append(groups, g)
	}
	return groups, nil
}

// GetWorkoutSegmentsByGroupID retrieves all segments for a workout group
func (db *DB) GetWorkoutSegmentsByGroupID(ctx context.Context, groupID int) ([]models.WorkoutSegment, error) {
	query := `SELECT id, workout_group_id, segment_type, repetitions, rest, targets FROM workout_segments WHERE workout_group_id = $1 ORDER BY id`
	rows, err := db.QueryContext(ctx, query, groupID)
	if err != nil {
		return nil, fmt.Errorf("failed to query workout segments: %w", err)
	}
	defer rows.Close()

	var segments []models.WorkoutSegment
	for rows.Next() {
		var s models.WorkoutSegment
		err := rows.Scan(&s.ID, &s.WorkoutGroupID, &s.SegmentType, &s.Repetitions, &s.Rest, &s.Targets)
		if err != nil {
			return nil, fmt.Errorf("failed to scan workout segment: %w", err)
		}
		segments = append(segments, s)
	}
	return segments, nil
}

// UpdateWorkoutAPI updates an existing workout with groups and segments
func (db *DB) UpdateWorkoutAPI(ctx context.Context, id int, date, location, startTime, coachNotes string, emailID int, groups []models.WorkoutGroup) error {
	var startTimeParam interface{}
	if startTime == "" {
		startTimeParam = nil
	} else {
		startTimeParam = startTime
	}

	query := `
		UPDATE workouts
		SET date = $2, location = $3, start_time = $4, coach_notes = $5, email_id = $6
		WHERE id = $1
	`
	_, err := db.ExecContext(ctx, query, id, date, location, startTimeParam, coachNotes, emailID)
	if err != nil {
		return fmt.Errorf("failed to update workout: %w", err)
	}

	// Delete existing groups and segments, then recreate them
	err = db.DeleteWorkoutGroupsAndSegments(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to delete existing groups and segments: %w", err)
	}

	// Insert new groups and segments
	for _, group := range groups {
		groupID, err := db.InsertWorkoutGroupAPI(ctx, id, group.GroupName, group.Description)
		if err != nil {
			return fmt.Errorf("failed to insert workout group: %w", err)
		}

		for _, segment := range group.Segments {
			err = db.InsertWorkoutSegmentAPI(ctx, groupID, segment.SegmentType, segment.Repetitions, segment.Rest, segment.Targets)
			if err != nil {
				return fmt.Errorf("failed to insert workout segment: %w", err)
			}
		}
	}

	return nil
}

// DeleteWorkoutGroupsAndSegments removes all groups and segments for a workout
func (db *DB) DeleteWorkoutGroupsAndSegments(ctx context.Context, workoutID int) error {
	// Delete segments first (due to foreign key constraints)
	query := `DELETE FROM workout_segments WHERE workout_group_id IN (SELECT id FROM workout_groups WHERE workout_id = $1)`
	_, err := db.ExecContext(ctx, query, workoutID)
	if err != nil {
		return fmt.Errorf("failed to delete workout segments: %w", err)
	}

	// Then delete groups
	query = `DELETE FROM workout_groups WHERE workout_id = $1`
	_, err = db.ExecContext(ctx, query, workoutID)
	if err != nil {
		return fmt.Errorf("failed to delete workout groups: %w", err)
	}

	return nil
}

// DeleteWorkout removes a workout from the database (cascades to groups and segments)
func (db *DB) DeleteWorkout(ctx context.Context, id int) error {
	query := `DELETE FROM workouts WHERE id = $1`
	_, err := db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete workout: %w", err)
	}
	return nil
}

// AthleteDetailsResponse represents comprehensive athlete information
type AthleteDetailsResponse struct {
	Athlete          *models.Athlete           `json:"athlete"`
	RacePerformances []RacePerformanceWithRace `json:"race_performances"`
	Nicknames        []*models.AthleteNickname `json:"nicknames"`
}

// RacePerformanceWithRace represents a race result joined with race information
type RacePerformanceWithRace struct {
	RaceResult *models.RaceResult `json:"race_result"`
	Race       *models.Race       `json:"race"`
}

// GetAthleteDetails retrieves comprehensive information for a specific athlete
func (db *DB) GetAthleteDetails(ctx context.Context, athleteID int) (*AthleteDetailsResponse, error) {
	// Get athlete info
	athlete, err := db.GetAthleteByID(ctx, athleteID)
	if err != nil {
		return nil, fmt.Errorf("failed to get athlete: %w", err)
	}
	if athlete == nil {
		return nil, nil // Athlete not found
	}

	// Get race performances with race details
	racePerformances, err := db.getAthleteRacePerformances(ctx, athleteID)
	if err != nil {
		return nil, fmt.Errorf("failed to get race performances: %w", err)
	}

	// Get nicknames
	nicknames, err := db.GetAthleteNicknames(ctx, &athleteID, "", 1000, 0) // Get all nicknames for this athlete
	if err != nil {
		return nil, fmt.Errorf("failed to get nicknames: %w", err)
	}

	return &AthleteDetailsResponse{
		Athlete:          athlete,
		RacePerformances: racePerformances,
		Nicknames:        nicknames,
	}, nil
}

// GetAllAthleteDetails retrieves comprehensive information for all athletes
func (db *DB) GetAllAthleteDetails(ctx context.Context) ([]AthleteDetailsResponse, error) {
	// Get all athletes
	athletes, err := db.GetAthletes(ctx, "", "", nil, 10000, 0) // Get all athletes
	if err != nil {
		return nil, fmt.Errorf("failed to get athletes: %w", err)
	}

	// Build athlete details for each
	allDetails := make([]AthleteDetailsResponse, 0, len(athletes))
	for _, athlete := range athletes {
		// Get race performances with race details
		racePerformances, err := db.getAthleteRacePerformances(ctx, athlete.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get race performances for athlete %d: %w", athlete.ID, err)
		}

		// Get nicknames
		nicknames, err := db.GetAthleteNicknames(ctx, &athlete.ID, "", 1000, 0)
		if err != nil {
			return nil, fmt.Errorf("failed to get nicknames for athlete %d: %w", athlete.ID, err)
		}

		allDetails = append(allDetails, AthleteDetailsResponse{
			Athlete:          athlete,
			RacePerformances: racePerformances,
			Nicknames:        nicknames,
		})
	}

	return allDetails, nil
}

// getAthleteRacePerformances gets all race results for an athlete with joined race information
func (db *DB) getAthleteRacePerformances(ctx context.Context, athleteID int) ([]RacePerformanceWithRace, error) {
	query := `
		SELECT 
			rr.id, rr.race_id, rr.athlete_id, rr.unknown_athlete_name, rr.time, rr.pr_improvement, rr.notes, rr.position, rr.is_pr, rr.is_club_record, rr.tags, rr.flagged, rr.flag_reason, rr.email_id, rr.date_recorded,
			r.id, r.name, r.date, r.year, r.distance, r.notes, r.email_id
		FROM race_results rr
		JOIN races r ON rr.race_id = r.id
		WHERE rr.athlete_id = $1
		ORDER BY r.date DESC NULLS LAST, rr.id DESC
	`

	rows, err := db.QueryContext(ctx, query, athleteID)
	if err != nil {
		return nil, fmt.Errorf("failed to query race performances: %w", err)
	}
	defer rows.Close()

	var performances []RacePerformanceWithRace
	for rows.Next() {
		var perf RacePerformanceWithRace
		var rr models.RaceResult
		var r models.Race
		var tags pq.StringArray

		err := rows.Scan(
			&rr.ID, &rr.RaceID, &rr.AthleteID, &rr.UnknownAthleteName, &rr.Time, &rr.PRImprovement, &rr.Notes, &rr.Position, &rr.IsPR, &rr.IsClubRecord, &tags, &rr.Flagged, &rr.FlagReason, &rr.EmailID, &rr.DateRecorded,
			&r.ID, &r.Name, &r.Date, &r.Year, &r.Distance, &r.Notes, &r.EmailID,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan race performance: %w", err)
		}

		rr.Tags = []string(tags)
		perf.RaceResult = &rr
		perf.Race = &r
		performances = append(performances, perf)
	}

	return performances, nil
}

// EmailDetailsResponse represents all parsed data associated with an email
type EmailDetailsResponse struct {
	Email       *models.Email        `json:"email"`
	Athletes    []*models.Athlete    `json:"athletes"`
	Races       []*models.Race       `json:"races"`
	RaceResults []*models.RaceResult `json:"race_results"`
	Workouts    []*models.Workout    `json:"workouts"`
}

// GetEmailDetails retrieves comprehensive information for a specific email including all associated data
func (db *DB) GetEmailDetails(ctx context.Context, emailID int) (*EmailDetailsResponse, error) {
	// Get the email itself
	email, err := db.GetEmailByID(ctx, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to get email: %w", err)
	}
	if email == nil {
		return nil, nil // Email not found
	}

	// Get athletes associated with this email
	athletes, err := db.getAthletesByEmailID(ctx, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to get athletes: %w", err)
	}

	// Get races associated with this email
	races, err := db.getRacesByEmailID(ctx, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to get races: %w", err)
	}

	// Get race results associated with this email
	raceResults, err := db.getRaceResultsByEmailID(ctx, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to get race results: %w", err)
	}

	// Get workouts associated with this email
	workouts, err := db.getWorkoutsByEmailID(ctx, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to get workouts: %w", err)
	}

	return &EmailDetailsResponse{
		Email:       email,
		Athletes:    athletes,
		Races:       races,
		RaceResults: raceResults,
		Workouts:    workouts,
	}, nil
}

// getAthletesByEmailID gets all athletes that have race results from a specific email
func (db *DB) getAthletesByEmailID(ctx context.Context, emailID int) ([]*models.Athlete, error) {
	query := `
		SELECT DISTINCT a.id, a.name, a.gender, a.active, a.website_url
		FROM athletes a
		JOIN race_results rr ON a.id = rr.athlete_id
		WHERE rr.email_id = $1
		ORDER BY a.name
	`

	rows, err := db.QueryContext(ctx, query, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to query athletes: %w", err)
	}
	defer rows.Close()

	var athletes []*models.Athlete
	for rows.Next() {
		var athlete models.Athlete
		err := rows.Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
		if err != nil {
			return nil, fmt.Errorf("failed to scan athlete: %w", err)
		}
		athletes = append(athletes, &athlete)
	}
	return athletes, nil
}

// getRacesByEmailID gets all races associated with a specific email
func (db *DB) getRacesByEmailID(ctx context.Context, emailID int) ([]*models.Race, error) {
	query := `SELECT id, name, date, distance, type, notes, email_id FROM races WHERE email_id = $1 ORDER BY date DESC`

	rows, err := db.QueryContext(ctx, query, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to query races: %w", err)
	}
	defer rows.Close()

	var races []*models.Race
	for rows.Next() {
		var race models.Race
		err := rows.Scan(&race.ID, &race.Name, &race.Date, &race.Distance, &race.Type, &race.Notes, &race.EmailID)
		if err != nil {
			return nil, fmt.Errorf("failed to scan race: %w", err)
		}
		races = append(races, &race)
	}
	return races, nil
}

// getRaceResultsByEmailID gets all race results associated with a specific email
func (db *DB) getRaceResultsByEmailID(ctx context.Context, emailID int) ([]*models.RaceResult, error) {
	query := `SELECT id, race_id, athlete_id, unknown_athlete_name, time, pr_improvement, notes, position, is_pr, tags, flagged, flag_reason, email_id, date_recorded FROM race_results WHERE email_id = $1 ORDER BY id`

	rows, err := db.QueryContext(ctx, query, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to query race results: %w", err)
	}
	defer rows.Close()

	var raceResults []*models.RaceResult
	for rows.Next() {
		var rr models.RaceResult
		var tags pq.StringArray
		err := rows.Scan(&rr.ID, &rr.RaceID, &rr.AthleteID, &rr.UnknownAthleteName, &rr.Time, &rr.PRImprovement, &rr.Notes, &rr.Position, &rr.IsPR, &tags, &rr.Flagged, &rr.FlagReason, &rr.EmailID, &rr.DateRecorded)
		if err != nil {
			return nil, fmt.Errorf("failed to scan race result: %w", err)
		}
		rr.Tags = []string(tags)
		raceResults = append(raceResults, &rr)
	}
	return raceResults, nil
}

// getWorkoutsByEmailID gets all workouts associated with a specific email
func (db *DB) getWorkoutsByEmailID(ctx context.Context, emailID int) ([]*models.Workout, error) {
	query := `SELECT id, date, location, start_time, coach_notes, email_id FROM workouts WHERE email_id = $1 ORDER BY date DESC`

	rows, err := db.QueryContext(ctx, query, emailID)
	if err != nil {
		return nil, fmt.Errorf("failed to query workouts: %w", err)
	}
	defer rows.Close()

	var workouts []*models.Workout
	for rows.Next() {
		var workout models.Workout
		err := rows.Scan(&workout.ID, &workout.Date, &workout.Location, &workout.StartTime, &workout.CoachNotes, &workout.EmailID)
		if err != nil {
			return nil, fmt.Errorf("failed to scan workout: %w", err)
		}
		workouts = append(workouts, &workout)
	}
	return workouts, nil
}

// GetYearlyStats aggregates stats for the current year
func (db *DB) GetYearlyStats(ctx context.Context) (*models.YearlyStats, error) {
	var stats models.YearlyStats
	yearQuery := "SELECT EXTRACT(YEAR FROM CURRENT_DATE)::int"
	var year int
	if err := db.QueryRowContext(ctx, yearQuery).Scan(&year); err != nil {
		return nil, err
	}

	// Count personal bests (is_pr = true)
	err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM race_results WHERE is_pr = true AND date_recorded IS NOT NULL AND EXTRACT(YEAR FROM date_recorded) = $1`, year).Scan(&stats.PersonalBests)
	if err != nil {
		return nil, err
	}

	// Count races competed (distinct race_id in race_results for this year)
	err = db.QueryRowContext(ctx, `SELECT COUNT(DISTINCT race_id) FROM race_results WHERE date_recorded IS NOT NULL AND EXTRACT(YEAR FROM date_recorded) = $1`, year).Scan(&stats.RacesCompeted)
	if err != nil {
		return nil, err
	}

	// Count club records (using is_club_record flag)
	err = db.QueryRowContext(ctx, `SELECT COUNT(*) FROM race_results WHERE is_club_record = TRUE AND date_recorded IS NOT NULL AND EXTRACT(YEAR FROM date_recorded) = $1`, year).Scan(&stats.ClubRecords)
	if err != nil {
		return nil, err
	}

	// Popular races: top 10 races by number of participants (race_results per race_id)
	rows, err := db.QueryContext(ctx, `SELECT r.name, COUNT(DISTINCT rr.athlete_id) AS participants FROM race_results rr JOIN races r ON rr.race_id = r.id WHERE rr.date_recorded IS NOT NULL AND EXTRACT(YEAR FROM rr.date_recorded) = $1 GROUP BY r.name ORDER BY participants DESC, r.name LIMIT 10`, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var entry models.PopularRaceEntry
		if err := rows.Scan(&entry.Race, &entry.Participants); err != nil {
			return nil, err
		}
		stats.PopularRaces = append(stats.PopularRaces, entry)
	}

	return &stats, nil
}
