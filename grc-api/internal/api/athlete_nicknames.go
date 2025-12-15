package api

import (
	"encoding/json"
	"grcapi/internal/db"
	"grcapi/internal/models"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
)

// AthleteNicknamesHandler handles athlete nickname-related endpoints
type AthleteNicknamesHandler struct {
	DB *db.DB
}

func NewAthleteNicknamesHandler(database *db.DB) *AthleteNicknamesHandler {
	return &AthleteNicknamesHandler{
		DB: database,
	}
}

func (h *AthleteNicknamesHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			h.getAthleteNickname(w, r, id)
		} else {
			h.listAthleteNicknames(w, r)
		}
	case http.MethodPost:
		h.createAthleteNickname(w, r)
	case http.MethodPut:
		if id := chi.URLParam(r, "id"); id != "" {
			h.updateAthleteNickname(w, r, id)
		} else {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Missing athlete nickname ID"))
		}
	case http.MethodDelete:
		if id := chi.URLParam(r, "id"); id != "" {
			h.deleteAthleteNickname(w, r, id)
		} else {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Missing athlete nickname ID"))
		}
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func (h *AthleteNicknamesHandler) listAthleteNicknames(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	athleteIDStr := r.URL.Query().Get("athlete_id")
	nickname := r.URL.Query().Get("nickname")
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	// Parse athlete_id filter
	var athleteID *int
	if athleteIDStr != "" {
		if parsed, err := strconv.Atoi(athleteIDStr); err == nil && parsed > 0 {
			athleteID = &parsed
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

	nicknames, err := h.DB.GetAthleteNicknames(r.Context(), athleteID, nickname, limit, offset)
	if err != nil {
		log.Printf("ERROR: Failed to get athlete nicknames: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete nicknames"))
		return
	}

	// Get total count for pagination
	total, err := h.DB.GetAthleteNicknamesCount(r.Context(), athleteID, nickname)
	if err != nil {
		log.Printf("ERROR: Failed to get athlete nicknames count: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete nicknames count"))
		return
	}

	response := map[string]interface{}{
		"data":   nicknames,
		"total":  total,
		"limit":  limit,
		"offset": offset,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthleteNicknamesHandler) getAthleteNickname(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete nickname ID"))
		return
	}

	nickname, err := h.DB.GetAthleteNicknameByID(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to get athlete nickname %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve athlete nickname"))
		return
	}
	if nickname == nil {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("Athlete nickname not found"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(nickname)
}

func (h *AthleteNicknamesHandler) createAthleteNickname(w http.ResponseWriter, r *http.Request) {
	var nickname models.AthleteNickname
	if err := json.NewDecoder(r.Body).Decode(&nickname); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}

	// Validate required fields
	if nickname.AthleteID <= 0 {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Valid athlete ID is required"))
		return
	}

	if strings.TrimSpace(nickname.Nickname) == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Nickname is required"))
		return
	}

	err := h.DB.InsertAthleteNicknameAPI(r.Context(), nickname.AthleteID, nickname.Nickname)
	if err != nil {
		log.Printf("ERROR: Failed to create athlete nickname: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to create athlete nickname"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthleteNicknamesHandler) updateAthleteNickname(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete nickname ID"))
		return
	}

	var nickname models.AthleteNickname
	if err := json.NewDecoder(r.Body).Decode(&nickname); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}

	// Validate required fields
	if nickname.AthleteID <= 0 {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Valid athlete ID is required"))
		return
	}

	if strings.TrimSpace(nickname.Nickname) == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Nickname is required"))
		return
	}

	err = h.DB.UpdateAthleteNickname(r.Context(), id, nickname.AthleteID, nickname.Nickname)
	if err != nil {
		log.Printf("ERROR: Failed to update athlete nickname %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to update athlete nickname"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *AthleteNicknamesHandler) deleteAthleteNickname(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid athlete nickname ID"))
		return
	}

	err = h.DB.DeleteAthleteNickname(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to delete athlete nickname %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to delete athlete nickname"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
