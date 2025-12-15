package service

import (
	"context"
	"encoding/json"
	"fmt"
	"grcapi/internal/models"
	"log"
	"os"
	"strings"

	"github.com/anthropics/anthropic-sdk-go"
	"github.com/anthropics/anthropic-sdk-go/option"
)

// ParsedEmailData represents the parsed output from LLM
// Should match the strict schema for athletes, races, race_results, workouts
type ParsedEmailData struct {
	Athletes    []ParsedAthlete    `json:"athletes"`
	Races       []ParsedRace       `json:"races"`
	RaceResults []ParsedRaceResult `json:"race_results"`
	Workouts    []ParsedWorkout    `json:"workouts"`
}

// Validate checks that required fields are present and valid
func (p *ParsedEmailData) Validate() error {
	for i, athlete := range p.Athletes {
		if strings.TrimSpace(athlete.Name) == "" {
			return fmt.Errorf("athlete %d: name cannot be empty", i+1)
		}
	}
	for i, race := range p.Races {
		if strings.TrimSpace(race.Name) == "" {
			return fmt.Errorf("race %d: name cannot be empty", i)
		}
	}
	for i, result := range p.RaceResults {
		if strings.TrimSpace(result.AthleteName) == "" {
			return fmt.Errorf("race_result %d: athlete_name cannot be empty", i)
		}
		if strings.TrimSpace(result.RaceName) == "" {
			return fmt.Errorf("race_result %d: race_name cannot be empty", i)
		}
	}
	// Workouts are optional, but if present, validate minimally
	for i, workout := range p.Workouts {
		if strings.TrimSpace(workout.Date) == "" {
			return fmt.Errorf("workout %d: date cannot be empty", i)
		}
		for j, group := range workout.Groups {
			if strings.TrimSpace(group.GroupName) == "" {
				return fmt.Errorf("workout %d group %d: group_name cannot be empty", i, j)
			}
			for _, segment := range group.Segments {
				// Description is optional - we'll provide defaults if empty
				_ = segment.Description // We validate this can be empty now
			}
		}
	}
	return nil
}

type ParsedAthlete struct {
	Name string `json:"name"` // Full name as it appears in the roster
}

type ParsedRace struct {
	Name     string `json:"name"`
	Date     string `json:"date"`
	Distance string `json:"distance"`
	Type     string `json:"type"`
}

type ParsedRaceResult struct {
	AthleteName  string   `json:"athlete_name"` // Will be matched to athlete table
	RaceName     string   `json:"race_name"`    // Will be matched to race table
	Time         string   `json:"time"`
	Position     *int     `json:"position"`
	IsPR         bool     `json:"is_pr"`
	IsClubRecord bool     `json:"is_club_record"`
	Notes        string   `json:"notes"`
	Tags         []string `json:"tags"`
	Flagged      bool     `json:"flagged"`     // True if LLM is uncertain about the match
	FlagReason   string   `json:"flag_reason"` // Reason for flagging (e.g., "ambiguous name", "not in roster")
}

type ParsedWorkout struct {
	Date        string               `json:"date"`
	Location    string               `json:"location"`
	Description string               `json:"description"`
	Groups      []ParsedWorkoutGroup `json:"groups"`
}

type ParsedWorkoutGroup struct {
	GroupName string                 `json:"group_name"`
	Segments  []ParsedWorkoutSegment `json:"segments"`
}

type ParsedWorkoutSegment struct {
	Reps        int    `json:"reps"`
	Distance    string `json:"distance"`
	TargetPace  string `json:"target_pace"`
	RestTime    string `json:"rest_time"`
	Description string `json:"description"`
}

// LLMParserService handles parsing of emails using Anthropic's Claude
type LLMParserService struct {
	APIKey         string
	PromptTemplate string
	AthleteMatcher *AthleteMatcherService
}

// NewLLMParserService creates a new LLM parser service
func NewLLMParserService(apiKey string, promptTemplatePath string, athleteMatcher *AthleteMatcherService) (*LLMParserService, error) {
	// Read the prompt template from file
	promptBytes, err := os.ReadFile(promptTemplatePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read prompt template: %w", err)
	}

	return &LLMParserService{
		APIKey:         apiKey,
		PromptTemplate: string(promptBytes),
		AthleteMatcher: athleteMatcher,
	}, nil
}

// ParseEmail sends email data to Anthropic API and returns parsed result
func (s *LLMParserService) ParseEmail(ctx context.Context, email *models.Email) (*ParsedEmailData, error) {
	log.Printf("Creating Anthropic client with API key length: %d", len(s.APIKey))

	// Validate email data before proceeding
	if strings.TrimSpace(email.Body) == "" {
		return nil, fmt.Errorf("email body is empty or missing")
	}
	if strings.TrimSpace(email.Title) == "" {
		log.Printf("Warning: email subject is empty")
	}

	client := anthropic.NewClient(
		option.WithAPIKey(s.APIKey),
	)

	// Get athlete roster for better name matching
	athleteRoster, err := s.AthleteMatcher.GetAthleteRosterForPrompt(ctx)
	if err != nil {
		log.Printf("Warning: failed to get athlete roster: %v", err)
		athleteRoster = "" // Continue without roster
	}

	// Populate the prompt template with email data
	prompt := s.PromptTemplate
	prompt = strings.ReplaceAll(prompt, "{{.AthleteRoster}}", athleteRoster)
	prompt = strings.ReplaceAll(prompt, "{{.Subject}}", email.Title)
	prompt = strings.ReplaceAll(prompt, "{{.Date}}", email.Date)
	prompt = strings.ReplaceAll(prompt, "{{.Sender}}", email.Sender)
	prompt = strings.ReplaceAll(prompt, "{{.Body}}", email.Body)

	// Verify that the body was actually replaced in the prompt
	if !strings.Contains(prompt, email.Body) && strings.TrimSpace(email.Body) != "" {
		log.Printf("ERROR: Email body was not properly inserted into prompt template")
		return nil, fmt.Errorf("failed to populate prompt template with email body")
	}

	log.Printf("Sending prompt to Claude - Subject: '%s', Body length: %d chars", email.Title, len(email.Body))

	// Final check: ensure the prompt contains the body section
	if !strings.Contains(prompt, "Body:") {
		log.Printf("ERROR: Prompt template missing 'Body:' section")
		return nil, fmt.Errorf("email body section not found in generated prompt")
	}
	if !strings.Contains(prompt, email.Body) && strings.TrimSpace(email.Body) != "" {
		log.Printf("ERROR: Email body content not found in prompt")
		return nil, fmt.Errorf("email body content not found in generated prompt")
	}

	log.Printf("Sending prompt to Claude - Subject: '%s', Body length: %d chars", email.Title, len(email.Body))

	log.Printf("Making Anthropic API call with model: %s", anthropic.ModelClaude3_5HaikuLatest)

	message, err := client.Messages.New(ctx, anthropic.MessageNewParams{
		Model:     anthropic.ModelClaude3_5HaikuLatest,
		MaxTokens: 4096,
		Messages: []anthropic.MessageParam{
			anthropic.NewUserMessage(anthropic.NewTextBlock(prompt)),
		},
	})

	if err != nil {
		log.Printf("Anthropic API error details: %v", err)
		return nil, fmt.Errorf("anthropic API call failed: %w", err)
	}

	if len(message.Content) == 0 {
		return nil, fmt.Errorf("no content in response")
	}

	// Extract text from response
	responseText := message.Content[0].Text

	// Parse JSON response
	var parsed ParsedEmailData
	if err := json.Unmarshal([]byte(responseText), &parsed); err != nil {
		log.Printf("ERROR: Failed to parse LLM JSON response: %v", err)
		return nil, fmt.Errorf("failed to parse JSON response: %w", err)
	}

	// Validate the parsed data
	if err := parsed.Validate(); err != nil {
		log.Printf("ERROR: Validation failed for parsed LLM response: %v", err)
		return nil, fmt.Errorf("validation failed for parsed data: %w", err)
	}

	log.Printf("Successfully parsed LLM response - %d athletes, %d races, %d results, %d workouts",
		len(parsed.Athletes), len(parsed.Races), len(parsed.RaceResults), len(parsed.Workouts))
	return &parsed, nil
}

// ParseEmailWithDebug sends email data to Anthropic API and returns parsed result with debug info
func (s *LLMParserService) ParseEmailWithDebug(ctx context.Context, email *models.Email) (*ParsedEmailData, string, string, error) {
	log.Printf("Creating Anthropic client with API key length: %d", len(s.APIKey))

	// Validate email data before proceeding
	if strings.TrimSpace(email.Body) == "" {
		return nil, "", "", fmt.Errorf("email body is empty or missing")
	}
	if strings.TrimSpace(email.Title) == "" {
		log.Printf("Warning: email subject is empty")
	}

	client := anthropic.NewClient(
		option.WithAPIKey(s.APIKey),
	)

	// Get athlete roster for better name matching
	athleteRoster, err := s.AthleteMatcher.GetAthleteRosterForPrompt(ctx)
	if err != nil {
		log.Printf("Warning: failed to get athlete roster: %v", err)
		athleteRoster = "" // Continue without roster
	}

	// Populate the prompt template with email data
	prompt := s.PromptTemplate
	prompt = strings.ReplaceAll(prompt, "{{.AthleteRoster}}", athleteRoster)
	prompt = strings.ReplaceAll(prompt, "{{.Subject}}", email.Title)
	prompt = strings.ReplaceAll(prompt, "{{.Date}}", email.Date)
	prompt = strings.ReplaceAll(prompt, "{{.Sender}}", email.Sender)
	prompt = strings.ReplaceAll(prompt, "{{.Body}}", email.Body)

	// Verify that the body was actually replaced in the prompt
	if !strings.Contains(prompt, email.Body) && strings.TrimSpace(email.Body) != "" {
		log.Printf("ERROR: Email body was not properly inserted into prompt template")
		return nil, "", "", fmt.Errorf("failed to populate prompt template with email body")
	}

	log.Printf("Sending prompt to Claude - Subject: '%s', Body length: %d chars", email.Title, len(email.Body))

	// Final check: ensure the prompt contains the body section
	if !strings.Contains(prompt, "Body:") {
		log.Printf("ERROR: Prompt template missing 'Body:' section")
		return nil, "", "", fmt.Errorf("email body section not found in generated prompt")
	}
	if !strings.Contains(prompt, email.Body) && strings.TrimSpace(email.Body) != "" {
		log.Printf("ERROR: Email body content not found in prompt")
		return nil, "", "", fmt.Errorf("email body content not found in generated prompt")
	}

	log.Printf("Sending prompt to Claude - Subject: '%s', Body length: %d chars", email.Title, len(email.Body))

	log.Printf("Making Anthropic API call with model: %s", anthropic.ModelClaude3_5HaikuLatest)

	message, err := client.Messages.New(ctx, anthropic.MessageNewParams{
		Model:     anthropic.ModelClaude3_5HaikuLatest,
		MaxTokens: 4096,
		Messages: []anthropic.MessageParam{
			anthropic.NewUserMessage(anthropic.NewTextBlock(prompt)),
		},
	})

	if err != nil {
		log.Printf("Anthropic API error details: %v", err)
		return nil, "", "", fmt.Errorf("anthropic API call failed: %w", err)
	}

	if len(message.Content) == 0 {
		return nil, "", "", fmt.Errorf("no content in response")
	}

	// Extract text from response
	responseText := message.Content[0].Text

	// Parse JSON response
	var parsed ParsedEmailData
	if err := json.Unmarshal([]byte(responseText), &parsed); err != nil {
		log.Printf("ERROR: Failed to parse LLM JSON response: %v", err)
		return nil, prompt, responseText, fmt.Errorf("failed to parse JSON response: %w", err)
	}

	// Validate the parsed data
	if err := parsed.Validate(); err != nil {
		log.Printf("ERROR: Validation failed for parsed LLM response: %v", err)
		return nil, prompt, responseText, fmt.Errorf("validation failed for parsed data: %w", err)
	}

	log.Printf("Successfully parsed LLM response - %d athletes, %d races, %d results, %d workouts",
		len(parsed.Athletes), len(parsed.Races), len(parsed.RaceResults), len(parsed.Workouts))
	return &parsed, prompt, responseText, nil
}
