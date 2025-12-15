package api

import (
	"encoding/json"
	"github.com/grcwrapped/grcapi/internal/db"
	"net/http"
)

type YearlyStatsHandler struct {
	db *db.DB
}

func NewYearlyStatsHandler(db *db.DB) *YearlyStatsHandler {
	return &YearlyStatsHandler{db: db}
}

func (h *YearlyStatsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	ctx := r.Context()
	stats, err := h.db.GetYearlyStats(ctx)
	if err != nil {
		http.Error(w, "Failed to get yearly stats: "+err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}
