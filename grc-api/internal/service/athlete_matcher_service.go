package service

import (
	"context"
	"database/sql"
	"fmt"
	"grcapi/internal/db"
	"grcapi/internal/models"
	"strings"

	"github.com/lib/pq"
)

// AthleteMatcherService handles matching athlete names from emails to database records
type AthleteMatcherService struct {
	DB *db.DB
}

func NewAthleteMatcherService(database *db.DB) *AthleteMatcherService {
	return &AthleteMatcherService{
		DB: database,
	}
}

// GetAthleteRosterForPrompt returns a formatted list of athletes for LLM prompt
func (s *AthleteMatcherService) GetAthleteRosterForPrompt(ctx context.Context) (string, error) {
	query := `
		SELECT 
			a.id,
			a.name,
			a.gender,
			COALESCE(array_agg(an.nickname) FILTER (WHERE an.nickname IS NOT NULL), ARRAY[]::text[]) as nicknames
		FROM athletes a
		LEFT JOIN athlete_nicknames an ON a.id = an.athlete_id
		WHERE a.active = true
		GROUP BY a.id, a.name, a.gender
		ORDER BY a.name
	`

	rows, err := s.DB.QueryContext(ctx, query)
	if err != nil {
		return "", fmt.Errorf("failed to fetch athlete roster: %w", err)
	}
	defer rows.Close()

	var builder strings.Builder
	builder.WriteString("ACTIVE ATHLETE ROSTER:\n")
	builder.WriteString("When you see a name in the email, match it to one of these athletes:\n\n")

	for rows.Next() {
		var id int
		var name string
		var gender sql.NullString
		var nicknames pq.StringArray

		err := rows.Scan(&id, &name, &gender, &nicknames)
		if err != nil {
			return "", fmt.Errorf("failed to scan row: %w", err)
		}

		genderStr := "Unknown"
		if gender.Valid {
			genderStr = gender.String
		}
		builder.WriteString(fmt.Sprintf("- %s (%s)", name, genderStr))
		if len(nicknames) > 0 && nicknames[0] != "" {
			builder.WriteString(fmt.Sprintf(" [also known as: %s]", strings.Join(nicknames, ", ")))
		}
		builder.WriteString("\n")
	}

	if err = rows.Err(); err != nil {
		return "", fmt.Errorf("rows error: %w", err)
	}

	builder.WriteString("\nIMPORTANT: Always use the full name from the roster above in your JSON output.\n")
	builder.WriteString("If you see a nickname or first name only, match it to the full name from this list.\n")
	builder.WriteString("AMBIGUOUS NAMES: If a nickname could match multiple people (e.g., 'Tom' could be Tom Harrison or Tom Slattery), use context from the email (race times, locations, workout groups) to determine which person it refers to.\n")
	builder.WriteString("If someone is mentioned but NOT in this roster, still include them with the name as written in the email.\n")

	return builder.String(), nil
}

// MatchAthleteName attempts to match a name from email to a database athlete
func (s *AthleteMatcherService) MatchAthleteName(ctx context.Context, mentionedName string) (*models.Athlete, error) {
	mentionedName = strings.TrimSpace(mentionedName)
	if mentionedName == "" {
		return nil, fmt.Errorf("empty name")
	}

	// Try exact match on full name
	athlete, err := s.exactMatchByName(ctx, mentionedName)
	if err == nil {
		return athlete, nil
	}

	// Try exact match on nickname (returns first match if multiple)
	athlete, err = s.exactMatchByNickname(ctx, mentionedName)
	if err == nil {
		return athlete, nil
	}

	// Try case-insensitive match
	athlete, err = s.caseInsensitiveMatch(ctx, mentionedName)
	if err == nil {
		return athlete, nil
	}

	// No match found
	return nil, fmt.Errorf("no athlete found for name: %s", mentionedName)
}

// FindAllMatchesByNickname returns all athletes that match a given nickname
// Useful for detecting ambiguous names like "Tom" -> [Tom Harrison, Tom Slattery]
func (s *AthleteMatcherService) FindAllMatchesByNickname(ctx context.Context, nickname string) ([]*models.Athlete, error) {
	query := `
		SELECT DISTINCT a.id, a.name, a.gender, a.active, a.website_url FROM athletes a
		JOIN athlete_nicknames an ON a.id = an.athlete_id
		WHERE an.nickname = $1
		ORDER BY a.name
	`

	rows, err := s.DB.QueryContext(ctx, query, nickname)
	if err != nil {
		return nil, fmt.Errorf("failed to query nicknames: %w", err)
	}
	defer rows.Close()

	var athletes []*models.Athlete
	for rows.Next() {
		var athlete models.Athlete
		err := rows.Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		athletes = append(athletes, &athlete)
	}

	if len(athletes) == 0 {
		return nil, fmt.Errorf("no athletes found for nickname: %s", nickname)
	}

	return athletes, nil
}

func (s *AthleteMatcherService) exactMatchByName(ctx context.Context, name string) (*models.Athlete, error) {
	var athlete models.Athlete
	err := s.DB.QueryRowContext(ctx, "SELECT id, name, gender, active, website_url FROM athletes WHERE name = $1 LIMIT 1", name).
		Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("no athlete with name: %s", name)
	}
	return &athlete, err
}

func (s *AthleteMatcherService) exactMatchByNickname(ctx context.Context, nickname string) (*models.Athlete, error) {
	query := `
		SELECT a.id, a.name, a.gender, a.active, a.website_url FROM athletes a
		JOIN athlete_nicknames an ON a.id = an.athlete_id
		WHERE an.nickname = $1
		LIMIT 1
	`
	var athlete models.Athlete
	err := s.DB.QueryRowContext(ctx, query, nickname).
		Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("no athlete with nickname: %s", nickname)
	}
	return &athlete, err
}

func (s *AthleteMatcherService) caseInsensitiveMatch(ctx context.Context, name string) (*models.Athlete, error) {
	// Try name
	var athlete models.Athlete
	err := s.DB.QueryRowContext(ctx, "SELECT id, name, gender, active, website_url FROM athletes WHERE LOWER(name) = LOWER($1) LIMIT 1", name).
		Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
	if err == nil {
		return &athlete, nil
	}

	// Try nickname
	query := `
		SELECT a.id, a.name, a.gender, a.active, a.website_url FROM athletes a
		JOIN athlete_nicknames an ON a.id = an.athlete_id
		WHERE LOWER(an.nickname) = LOWER($1)
		LIMIT 1
	`
	err = s.DB.QueryRowContext(ctx, query, name).
		Scan(&athlete.ID, &athlete.Name, &athlete.Gender, &athlete.Active, &athlete.WebsiteURL)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("no athlete found for name: %s", name)
	}
	return &athlete, err
}
