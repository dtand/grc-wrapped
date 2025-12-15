package api

import (
	"encoding/json"
	"github.com/grcwrapped/grcapi/internal/service"
	"log"
	"net/http"
)

// SyncEmailsRequest represents the expected request body for /sync_emails
type SyncEmailsRequest struct {
	StartDate string `json:"start_date"`
	Sender    string `json:"sender"`
	Recipient string `json:"recipient"`
}

// SyncEmailsResponse represents the response body for /sync_emails
type SyncEmailsResponse struct {
	EmailsProcessed int            `json:"emails_processed"`
	RecordsCreated  map[string]int `json:"records_created"`
	Errors          []string       `json:"errors"`
}

// SyncEmailsHandler handles the /sync_emails endpoint as a struct with dependencies
type SyncEmailsHandler struct {
	Service     *service.SyncEmailService
	AdminAPIKey string
}

func NewSyncEmailsHandler(adminAPIKey string, svc *service.SyncEmailService) *SyncEmailsHandler {
	return &SyncEmailsHandler{
		AdminAPIKey: adminAPIKey,
		Service:     svc,
	}
}

func (h *SyncEmailsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received sync_emails request from %s", r.RemoteAddr)
	apiKey := r.Header.Get("Authorization")
	if !h.isValidAPIKey(apiKey) {
		log.Printf("Unauthorized request - invalid API key")
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte("Unauthorized"))
		return
	}

	var req SyncEmailsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Printf("Failed to decode request body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request body"))
		return
	}
	log.Printf("Sync request parameters - StartDate: %s, Sender: %s, Recipient: %s", req.StartDate, req.Sender, req.Recipient)

	result, err := h.Service.SyncEmails(r.Context(), req.StartDate, req.Sender, req.Recipient)
	if err != nil {
		log.Printf("ERROR: SyncEmails failed: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Failed to sync emails"))
		return
	}
	log.Printf("Sync completed successfully - %d emails processed", result.EmailsProcessed)

	// Construct response
	resp := SyncEmailsResponse{
		EmailsProcessed: result.EmailsProcessed,
		RecordsCreated:  result.RecordsCreated,
		Errors:          result.Errors,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// isValidAPIKey checks if the provided API key is valid against the handler's AdminAPIKey
func (h *SyncEmailsHandler) isValidAPIKey(apiKey string) bool {
	return apiKey == h.AdminAPIKey
}
