package api

import (
	"encoding/json"
	"github.com/grcwrapped/grcapi/internal/db"
	"github.com/grcwrapped/grcapi/internal/models"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
)

// AthletesHandler handles athlete-related endpoints
type AthletesHandler struct {
	DB *db.DB
}

func NewAthletesHandler(database *db.DB) *AthletesHandler {
	return &AthletesHandler{
		DB: database,
	}
}

func (h *AthletesHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		id := chi.URLParam(r, "id")

		// Check for /athletes/details first (bulk details without ID)
		if id == "details" || (strings.HasSuffix(r.URL.Path, "/details") && id == "") {
			h.getAllAthleteDetails(w, r)
		} else if id != "" {
			// Individual athlete routes
			if strings.HasSuffix(r.URL.Path, "/details") {
				h.getAthleteDetails(w, r, id)
			} else {
				h.getAthlete(w, r, id)
			}
		} else {
			// List all athletes
			h.listAthletes(w, r)
		}
	case http.MethodPost:
		h.createAthlete(w, r)
	case http.MethodPut:
		if id := chi.URLParam(r, "id"); id != "" {
			h.updateAthlete(w, r, id)
		} else {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Missing athlete ID"))
		}
	case http.MethodDelete:
		if id := chi.URLParam(r, "id"); id != "" {
			h.deleteAthlete(w, r, id)
		} else {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Missing athlete ID"))
		}
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func (h *AthletesHandler) listAthletes(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	name := r.URL.Query().Get("name")
	gender := r.URL.Query().Get("gender")
	activeStr := r.URL.Query().Get("active")
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	// Parse active filter
	var active *bool
	if activeStr != "" {
		if parsed, err := strconv.ParseBool(activeStr); err == nil {
			active = &parsed
		}
	}

	// Parse pagination
	limit := 50 // default
	if limitStr != "" {
		if parsed, err := strconv.Atoi(limitStr); err == nil && parsed > 0 {
			limit = parsed
		}
	}

	offset := 0 // default
	if offsetStr != "" {
		if parsed, err := strconv.Atoi(offsetStr); err == nil && parsed >= 0 {
			offset = parsed
		}
	}

	athletes, err := h.DB.GetAthletes(r.Context(), name, gender, active, limit, offset)
	if err != nil {
		log.Printf("ERROR: Failed to get athletes: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athletes"))
		return
	}

	// Get total count for pagination
	total, err := h.DB.GetAthletesCount(r.Context(), name, gender, active)
	if err != nil {
		log.Printf("ERROR: Failed to get athletes count: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athletes count"))
		return
	}

	response := map[string]interface{}{
		"data":   athletes,
		"total":  total,
		"limit":  limit,
		"offset": offset,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthletesHandler) getAthlete(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete ID"))
		return
	}

	athlete, err := h.DB.GetAthleteByID(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to get athlete %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete"))
		return
	}
	if athlete == nil {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("Athlete not found"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(athlete)
}

func (h *AthletesHandler) getAthleteDetails(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete ID"))
		return
	}

	athleteDetails, err := h.DB.GetAthleteDetails(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to get athlete details %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete details"))
		return
	}
	if athleteDetails == nil {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("Athlete not found"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(athleteDetails)
}

func (h *AthletesHandler) getAllAthleteDetails(w http.ResponseWriter, r *http.Request) {
	allDetails, err := h.DB.GetAllAthleteDetails(r.Context())
	if err != nil {
		log.Printf("ERROR: Failed to get all athlete details: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(allDetails)
}

func (h *AthletesHandler) createAthlete(w http.ResponseWriter, r *http.Request) {
	var athlete models.Athlete
	if err := json.NewDecoder(r.Body).Decode(&athlete); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}

	// Validate required fields
	if strings.TrimSpace(athlete.Name) == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Athlete name is required"))
		return
	}

	// Validate gender if provided
	if athlete.Gender.Valid && athlete.Gender.String != "" && athlete.Gender.String != "M" && athlete.Gender.String != "F" && athlete.Gender.String != "NB" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Gender must be 'M', 'F', 'NB', or empty"))
		return
	}

	// Start transaction
	tx, err := h.DB.BeginTx(r.Context(), nil)
	if err != nil {
		log.Printf("ERROR: Failed to start transaction: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Database error"))
		return
	}
	defer tx.Rollback()

	// Convert sql.NullString to string for database function
	genderStr := ""
	if athlete.Gender.Valid {
		genderStr = athlete.Gender.String
	}

	id, err := h.DB.InsertAthlete(r.Context(), tx, athlete.Name, genderStr, athlete.Active, athlete.WebsiteURL)
	if err != nil {
		log.Printf("ERROR: Failed to create athlete: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to create athlete"))
		return
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		log.Printf("ERROR: Failed to commit transaction: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Database error"))
		return
	}

	response := map[string]interface{}{
		"success": true,
		"id":      id,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthletesHandler) updateAthlete(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete ID"))
		return
	}

	var athlete models.Athlete
	if err := json.NewDecoder(r.Body).Decode(&athlete); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}

	// Validate required fields
	if strings.TrimSpace(athlete.Name) == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Athlete name is required"))
		return
	}

	// Validate gender if provided
	if athlete.Gender.Valid && athlete.Gender.String != "" && athlete.Gender.String != "M" && athlete.Gender.String != "F" && athlete.Gender.String != "NB" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Gender must be 'M', 'F', 'NB', or empty"))
		return
	}

	// Convert sql.NullString to string for database function
	genderStr := ""
	if athlete.Gender.Valid {
		genderStr = athlete.Gender.String
	}

	err = h.DB.UpdateAthlete(r.Context(), id, athlete.Name, genderStr, athlete.Active, athlete.WebsiteURL)
	if err != nil {
		log.Printf("ERROR: Failed to update athlete %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to update athlete"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthletesHandler) deleteAthlete(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete ID"))
		return
	}

	err = h.DB.DeleteAthlete(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to delete athlete %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to delete athlete"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
