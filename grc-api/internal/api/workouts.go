package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/render"

	"grc-api/internal/db"
	"grc-api/internal/models"
)

type WorkoutsHandler struct {
	db *db.DB
}

func NewWorkoutsHandler(db *db.DB) *WorkoutsHandler {
	return &WorkoutsHandler{db: db}
}

func (h *WorkoutsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			h.GetWorkout(w, r)
		} else {
			h.GetWorkouts(w, r)
		}
	case http.MethodPost:
		h.CreateWorkout(w, r)
	case http.MethodPut:
		h.UpdateWorkout(w, r)
	case http.MethodDelete:
		h.DeleteWorkout(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func (h *WorkoutsHandler) GetWorkouts(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse query parameters
	date := r.URL.Query().Get("date")
	location := r.URL.Query().Get("location")
	emailIDStr := r.URL.Query().Get("email_id")

	var emailID *int
	if emailIDStr != "" {
		if id, err := strconv.Atoi(emailIDStr); err == nil {
			emailID = &id
		}
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

	workouts, err := h.db.GetWorkouts(ctx, date, location, emailID, limit, offset)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get workouts: %v", err), http.StatusInternalServerError)
		return
	}

	count, err := h.db.GetWorkoutsCount(ctx, date, location, emailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to count workouts: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"workouts": workouts,
		"total":    count,
		"limit":    limit,
		"offset":   offset,
	}

	render.JSON(w, r, response)
}

func (h *WorkoutsHandler) GetWorkout(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid workout ID", http.StatusBadRequest)
		return
	}

	workout, err := h.db.GetWorkoutByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get workout: %v", err), http.StatusInternalServerError)
		return
	}
	if workout == nil {
		http.Error(w, "Workout not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, workout)
}

func (h *WorkoutsHandler) CreateWorkout(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var req models.Workout
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if strings.TrimSpace(req.Date) == "" {
		http.Error(w, "Date is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	// Validate groups and segments
	for i, group := range req.Groups {
		if strings.TrimSpace(group.GroupName) == "" {
			http.Error(w, fmt.Sprintf("Group %d: group_name is required", i+1), http.StatusBadRequest)
			return
		}
		for j, segment := range group.Segments {
			if strings.TrimSpace(segment.SegmentType) == "" {
				http.Error(w, fmt.Sprintf("Group %d, Segment %d: segment_type is required", i+1, j+1), http.StatusBadRequest)
				return
			}
		}
	}

	// Insert the workout with groups and segments
	locationStr := ""
	if req.Location.Valid {
		locationStr = req.Location.String
	}
	startTimeStr := ""
	if req.StartTime.Valid {
		startTimeStr = req.StartTime.String
	}
	coachNotesStr := ""
	if req.CoachNotes.Valid {
		coachNotesStr = req.CoachNotes.String
	}

	id, err := h.db.InsertWorkoutAPI(ctx, req.Date, locationStr, startTimeStr, coachNotesStr, req.EmailID, req.Groups)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to create workout: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the created workout with all nested data
	workout, err := h.db.GetWorkoutByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve created workout: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	render.JSON(w, r, workout)
}

func (h *WorkoutsHandler) UpdateWorkout(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid workout ID", http.StatusBadRequest)
		return
	}

	var req models.Workout
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if strings.TrimSpace(req.Date) == "" {
		http.Error(w, "Date is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	// Validate groups and segments
	for i, group := range req.Groups {
		if strings.TrimSpace(group.GroupName) == "" {
			http.Error(w, fmt.Sprintf("Group %d: group_name is required", i+1), http.StatusBadRequest)
			return
		}
		for j, segment := range group.Segments {
			if strings.TrimSpace(segment.SegmentType) == "" {
				http.Error(w, fmt.Sprintf("Group %d, Segment %d: segment_type is required", i+1, j+1), http.StatusBadRequest)
				return
			}
		}
	}

	// Check if workout exists
	existing, err := h.db.GetWorkoutByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to check workout: %v", err), http.StatusInternalServerError)
		return
	}
	if existing == nil {
		http.Error(w, "Workout not found", http.StatusNotFound)
		return
	}

	// Update the workout with groups and segments
	locationStr := ""
	if req.Location.Valid {
		locationStr = req.Location.String
	}
	startTimeStr := ""
	if req.StartTime.Valid {
		startTimeStr = req.StartTime.String
	}
	coachNotesStr := ""
	if req.CoachNotes.Valid {
		coachNotesStr = req.CoachNotes.String
	}

	err = h.db.UpdateWorkoutAPI(ctx, id, req.Date, locationStr, startTimeStr, coachNotesStr, req.EmailID, req.Groups)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to update workout: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the updated workout with all nested data
	workout, err := h.db.GetWorkoutByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve updated workout: %v", err), http.StatusInternalServerError)
		return
	}

	render.JSON(w, r, workout)
}

func (h *WorkoutsHandler) DeleteWorkout(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid workout ID", http.StatusBadRequest)
		return
	}

	// Check if workout exists
	workout, err := h.db.GetWorkoutByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to check workout: %v", err), http.StatusInternalServerError)
		return
	}
	if workout == nil {
		http.Error(w, "Workout not found", http.StatusNotFound)
		return
	}

	err = h.db.DeleteWorkout(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to delete workout: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
