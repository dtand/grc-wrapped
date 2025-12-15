package api

import (
	"encoding/json"
	"github.com/grcwrapped/grcapi/internal/db"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
)

// ReviewFlagsHandler handles review flag-related admin endpoints
type ReviewFlagsHandler struct {
	DB          *db.DB
	AdminAPIKey string
}

func NewReviewFlagsHandler(database *db.DB, adminAPIKey string) *ReviewFlagsHandler {
	return &ReviewFlagsHandler{
		DB:          database,
		AdminAPIKey: adminAPIKey,
	}
}

func (h *ReviewFlagsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Check API key authentication
	apiKey := r.Header.Get("Authorization")
	if !h.isValidAPIKey(apiKey) {
		log.Printf("Unauthorized request to review flags - invalid API key")
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte("Unauthorized"))
		return
	}

	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			h.getReviewFlag(w, r, id)
		} else {
			h.listReviewFlags(w, r)
		}
	case http.MethodPut:
		if strings.HasSuffix(r.URL.Path, "/resolve") {
			id := strings.TrimSuffix(chi.URLParam(r, "id"), "/resolve")
			h.resolveReviewFlag(w, r, id)
		} else {
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func (h *ReviewFlagsHandler) listReviewFlags(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	resolvedStr := r.URL.Query().Get("resolved")
	flagType := r.URL.Query().Get("flag_type")
	entityType := r.URL.Query().Get("entity_type")
	emailIDStr := r.URL.Query().Get("email_id")
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	// Parse resolved filter (default false if not specified)
	var resolved *bool
	if resolvedStr != "" {
		if parsed, err := strconv.ParseBool(resolvedStr); err == nil {
			resolved = &parsed
		}
	} else {
		// Default to showing unresolved flags
		defaultResolved := false
		resolved = &defaultResolved
	}

	// Parse email_id filter
	var emailID *int
	if emailIDStr != "" {
		if parsed, err := strconv.Atoi(emailIDStr); err == nil && parsed > 0 {
			emailID = &parsed
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

	flags, err := h.DB.GetReviewFlags(r.Context(), resolved, flagType, entityType, emailID, limit, offset)
	if err != nil {
		log.Printf("ERROR: Failed to get review flags: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve review flags"))
		return
	}

	// Get total count for pagination
	total, err := h.DB.GetReviewFlagsCount(r.Context(), resolved, flagType, entityType, emailID)
	if err != nil {
		log.Printf("ERROR: Failed to get review flags count: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve review flags count"))
		return
	}

	response := map[string]interface{}{
		"data":   flags,
		"total":  total,
		"limit":  limit,
		"offset": offset,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *ReviewFlagsHandler) getReviewFlag(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid review flag ID"))
		return
	}

	flag, err := h.DB.GetReviewFlagByID(r.Context(), id)
	if err != nil {
		log.Printf("ERROR: Failed to get review flag %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to retrieve review flag"))
		return
	}
	if flag == nil {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("Review flag not found"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(flag)
}

func (h *ReviewFlagsHandler) resolveReviewFlag(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid review flag ID"))
		return
	}

	var req struct {
		ResolvedBy string `json:"resolved_by"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}

	// Validate required fields
	if strings.TrimSpace(req.ResolvedBy) == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("resolved_by is required"))
		return
	}

	err = h.DB.ResolveReviewFlag(r.Context(), id, req.ResolvedBy)
	if err != nil {
		log.Printf("ERROR: Failed to resolve review flag %d: %v", id, err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to resolve review flag"))
		return
	}

	response := map[string]interface{}{
		"success": true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// isValidAPIKey checks if the provided API key is valid
func (h *ReviewFlagsHandler) isValidAPIKey(apiKey string) bool {
	return apiKey == h.AdminAPIKey
}
