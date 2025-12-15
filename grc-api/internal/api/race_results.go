package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/render"

	"grcapi/internal/db"
	"grcapi/internal/models"
)

type RaceResultsHandler struct {
	db *db.DB
}

func NewRaceResultsHandler(db *db.DB) *RaceResultsHandler {
	return &RaceResultsHandler{db: db}
}

func (h *RaceResultsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			h.GetRaceResult(w, r)
		} else {
			h.GetRaceResults(w, r)
		}
	case http.MethodPost:
		h.CreateRaceResult(w, r)
	case http.MethodPut:
		h.UpdateRaceResult(w, r)
	case http.MethodDelete:
		h.DeleteRaceResult(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func (h *RaceResultsHandler) GetRaceResults(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse query parameters
	athleteIDStr := r.URL.Query().Get("athlete_id")
	raceIDStr := r.URL.Query().Get("race_id")
	isPRStr := r.URL.Query().Get("is_pr")
	isClubRecordStr := r.URL.Query().Get("is_club_record")
	tagsStr := r.URL.Query().Get("tags")
	positionStr := r.URL.Query().Get("position")
	flaggedStr := r.URL.Query().Get("flagged")
	emailIDStr := r.URL.Query().Get("email_id")
	dateRecordedStr := r.URL.Query().Get("date_recorded")
	dateRecordedFromStr := r.URL.Query().Get("date_recorded_from")
	dateRecordedToStr := r.URL.Query().Get("date_recorded_to")

	var athleteID, raceID, position, emailID *int
	var isPR, isClubRecord, flagged *bool
	var tags []string
	var dateRecorded, dateRecordedFrom, dateRecordedTo *string
	if isClubRecordStr != "" {
		if b, err := strconv.ParseBool(isClubRecordStr); err == nil {
			isClubRecord = &b
		}
	}

	if athleteIDStr != "" {
		if id, err := strconv.Atoi(athleteIDStr); err == nil {
			athleteID = &id
		}
	}
	if raceIDStr != "" {
		if id, err := strconv.Atoi(raceIDStr); err == nil {
			raceID = &id
		}
	}
	if isPRStr != "" {
		if b, err := strconv.ParseBool(isPRStr); err == nil {
			isPR = &b
		}
	}
	if tagsStr != "" {
		tags = strings.Split(tagsStr, ",")
		for i := range tags {
			tags[i] = strings.TrimSpace(tags[i])
		}
	}
	if positionStr != "" {
		if p, err := strconv.Atoi(positionStr); err == nil {
			position = &p
		}
	}
	if flaggedStr != "" {
		if b, err := strconv.ParseBool(flaggedStr); err == nil {
			flagged = &b
		}
	}
	if emailIDStr != "" {
		if id, err := strconv.Atoi(emailIDStr); err == nil {
			emailID = &id
		}
	}
	if dateRecordedStr != "" {
		dateRecorded = &dateRecordedStr
	}
	if dateRecordedFromStr != "" {
		dateRecordedFrom = &dateRecordedFromStr
	}
	if dateRecordedToStr != "" {
		dateRecordedTo = &dateRecordedToStr
	}

	limitStr := r.URL.Query().Get("limit")
	limit := 50 // default limit
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 && l <= 100 {
			limit = l
		}
	}

	offsetStr := r.URL.Query().Get("offset")
	offset := 0 // default offset
	if offsetStr != "" {
		if o, err := strconv.Atoi(offsetStr); err == nil && o >= 0 {
			offset = o
		}
	}

	raceResults, err := h.db.GetRaceResults(ctx, athleteID, raceID, isPR, isClubRecord, tags, position, flagged, emailID, dateRecorded, dateRecordedFrom, dateRecordedTo, limit, offset)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get race results: %v", err), http.StatusInternalServerError)
		return
	}

	count, err := h.db.GetRaceResultsCount(ctx, athleteID, raceID, isPR, isClubRecord, tags, position, flagged, emailID, dateRecorded, dateRecordedFrom, dateRecordedTo)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to count race results: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"race_results": raceResults,
		"total":        count,
		"limit":        limit,
		"offset":       offset,
	}

	render.JSON(w, r, response)
}

func (h *RaceResultsHandler) GetRaceResult(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race result ID", http.StatusBadRequest)
		return
	}

	raceResult, err := h.db.GetRaceResultByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get race result: %v", err), http.StatusInternalServerError)
		return
	}
	if raceResult == nil {
		http.Error(w, "Race result not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, raceResult)
}

func (h *RaceResultsHandler) CreateRaceResult(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var req models.RaceResult
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if req.RaceID <= 0 {
		http.Error(w, "Valid race_id is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(req.Time) == "" {
		http.Error(w, "Time is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	// Insert the race result
	id, err := h.db.InsertRaceResultAPI(ctx, req.RaceID, req.AthleteID, req.UnknownAthleteName, req.Time, req.PRImprovement, req.Notes, req.Position, req.IsPR, req.IsClubRecord, req.Tags, req.Flagged, req.FlagReason, req.EmailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to create race result: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the created race result
	raceResult, err := h.db.GetRaceResultByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve created race result: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	render.JSON(w, r, raceResult)
}

func (h *RaceResultsHandler) UpdateRaceResult(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race result ID", http.StatusBadRequest)
		return
	}

	var req models.RaceResult
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if req.RaceID <= 0 {
		http.Error(w, "Valid race_id is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(req.Time) == "" {
		http.Error(w, "Time is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	err = h.db.UpdateRaceResult(ctx, id, req.RaceID, req.AthleteID, req.UnknownAthleteName, req.Time, req.PRImprovement, req.Notes, req.Position, req.IsPR, req.IsClubRecord, req.Tags, req.Flagged, req.FlagReason, req.EmailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to update race result: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the updated race result
	raceResult, err := h.db.GetRaceResultByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve updated race result: %v", err), http.StatusInternalServerError)
		return
	}
	if raceResult == nil {
		http.Error(w, "Race result not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, raceResult)
}

func (h *RaceResultsHandler) DeleteRaceResult(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race result ID", http.StatusBadRequest)
		return
	}

	// Check if race result exists
	raceResult, err := h.db.GetRaceResultByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to check race result: %v", err), http.StatusInternalServerError)
		return
	}
	if raceResult == nil {
		http.Error(w, "Race result not found", http.StatusNotFound)
		return
	}

	err = h.db.DeleteRaceResult(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to delete race result: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
