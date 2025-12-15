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

type RacesHandler struct {
	db *db.DB
}

func NewRacesHandler(db *db.DB) *RacesHandler {
	return &RacesHandler{db: db}
}

func (h *RacesHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			h.GetRace(w, r)
		} else {
			h.GetRaces(w, r)
		}
	case http.MethodPost:
		h.CreateRace(w, r)
	case http.MethodPut:
		h.UpdateRace(w, r)
	case http.MethodDelete:
		h.DeleteRace(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func (h *RacesHandler) GetRaces(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse query parameters
	name := r.URL.Query().Get("name")
	year := r.URL.Query().Get("year")
	distance := r.URL.Query().Get("distance")
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

	races, err := h.db.GetRaces(ctx, name, year, distance, emailID, limit, offset)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get races: %v", err), http.StatusInternalServerError)
		return
	}

	count, err := h.db.GetRacesCount(ctx, name, year, distance, emailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to count races: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"races":  races,
		"total":  count,
		"limit":  limit,
		"offset": offset,
	}

	render.JSON(w, r, response)
}

func (h *RacesHandler) GetRace(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race ID", http.StatusBadRequest)
		return
	}

	race, err := h.db.GetRaceByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get race: %v", err), http.StatusInternalServerError)
		return
	}
	if race == nil {
		http.Error(w, "Race not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, race)
}

func (h *RacesHandler) CreateRace(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var req models.Race
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if strings.TrimSpace(req.Name) == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	if req.Year <= 0 {
		http.Error(w, "Valid year is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(req.Distance) == "" {
		http.Error(w, "Distance is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	// Insert the race
	id, err := h.db.InsertRaceAPI(ctx, req.Name, req.Date, req.Distance, req.Type, req.Notes, req.Year, req.EmailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to create race: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the created race
	race, err := h.db.GetRaceByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve created race: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	render.JSON(w, r, race)
}

func (h *RacesHandler) UpdateRace(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race ID", http.StatusBadRequest)
		return
	}

	var req models.Race
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if strings.TrimSpace(req.Name) == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	if req.Year <= 0 {
		http.Error(w, "Valid year is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(req.Distance) == "" {
		http.Error(w, "Distance is required", http.StatusBadRequest)
		return
	}
	if req.EmailID <= 0 {
		http.Error(w, "Valid email_id is required", http.StatusBadRequest)
		return
	}

	err = h.db.UpdateRace(ctx, id, req.Name, req.Date, req.Distance, req.Type, req.Notes, req.Year, req.EmailID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to update race: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the updated race
	race, err := h.db.GetRaceByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to retrieve updated race: %v", err), http.StatusInternalServerError)
		return
	}
	if race == nil {
		http.Error(w, "Race not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, race)
}

func (h *RacesHandler) DeleteRace(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid race ID", http.StatusBadRequest)
		return
	}

	// Check if race exists
	race, err := h.db.GetRaceByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to check race: %v", err), http.StatusInternalServerError)
		return
	}
	if race == nil {
		http.Error(w, "Race not found", http.StatusNotFound)
		return
	}

	err = h.db.DeleteRace(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to delete race: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
