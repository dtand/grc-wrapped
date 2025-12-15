package api

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/render"

	"grcapi/internal/db"
)

type EmailsHandler struct {
	db          *db.DB
	adminAPIKey string
}

func NewEmailsHandler(db *db.DB, adminAPIKey string) *EmailsHandler {
	return &EmailsHandler{db: db, adminAPIKey: adminAPIKey}
}

func (h *EmailsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Check API key authentication
	apiKey := r.Header.Get("Authorization")
	if !h.isValidAPIKey(apiKey) {
		log.Printf("Unauthorized request to emails - invalid API key")
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte("Unauthorized"))
		return
	}

	switch r.Method {
	case http.MethodGet:
		if id := chi.URLParam(r, "id"); id != "" {
			if strings.HasSuffix(r.URL.Path, "/details") {
				h.GetEmailDetails(w, r)
			} else {
				h.GetEmail(w, r)
			}
		} else {
			h.GetEmails(w, r)
		}
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func (h *EmailsHandler) GetEmails(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse query parameters
	title := r.URL.Query().Get("title")
	sender := r.URL.Query().Get("sender")
	recipient := r.URL.Query().Get("recipient")
	date := r.URL.Query().Get("date")

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

	emails, err := h.db.GetEmails(ctx, title, sender, recipient, date, limit, offset)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get emails: %v", err), http.StatusInternalServerError)
		return
	}

	count, err := h.db.GetEmailsCount(ctx, title, sender, recipient, date)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to count emails: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"emails": emails,
		"total":  count,
		"limit":  limit,
		"offset": offset,
	}

	render.JSON(w, r, response)
}

func (h *EmailsHandler) GetEmail(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid email ID", http.StatusBadRequest)
		return
	}

	email, err := h.db.GetEmailByID(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get email: %v", err), http.StatusInternalServerError)
		return
	}
	if email == nil {
		http.Error(w, "Email not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, email)
}

// GetEmailDetails retrieves comprehensive information for a specific email including all associated data
func (h *EmailsHandler) GetEmailDetails(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid email ID", http.StatusBadRequest)
		return
	}

	emailDetails, err := h.db.GetEmailDetails(ctx, id)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get email details: %v", err), http.StatusInternalServerError)
		return
	}
	if emailDetails == nil {
		http.Error(w, "Email not found", http.StatusNotFound)
		return
	}

	render.JSON(w, r, emailDetails)
}

// isValidAPIKey checks if the provided API key is valid
func (h *EmailsHandler) isValidAPIKey(apiKey string) bool {
	return apiKey == h.adminAPIKey
}
