package service

import (
	"context"
	"fmt"
	"io"
	"strings"
	"time"

	"github.com/grcwrapped/grcapi/config"

	"github.com/emersion/go-imap"
	"github.com/emersion/go-imap/client"
	"github.com/emersion/go-message/mail"
)

// Email represents a parsed email message
type Email struct {
	ID       string
	Subject  string
	From     string
	To       string
	Date     time.Time
	Body     string
	BodyHTML string
}

// FetchEmailsService holds IMAP credentials for fetching emails
type FetchEmailsService struct {
	Email    string
	Password string
}

// NewFetchEmailsService creates a new FetchEmailsService from config
func NewFetchEmailsService(cfg *config.Config) *FetchEmailsService {
	return &FetchEmailsService{
		Email:    cfg.GmailEmail,
		Password: cfg.GmailPassword,
	}
}

// FetchFilteredEmails authenticates via IMAP and fetches emails matching the criteria
func (s *FetchEmailsService) FetchFilteredEmails(ctx context.Context, sender, recipient, startDate string) ([]*Email, error) {
	// Connect to Gmail IMAP server
	c, err := client.DialTLS("imap.gmail.com:993", nil)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to IMAP: %v", err)
	}
	defer c.Logout()

	// Login
	if err := c.Login(s.Email, s.Password); err != nil {
		return nil, fmt.Errorf("failed to login: %v", err)
	}

	// Select INBOX
	_, err = c.Select("INBOX", false)
	if err != nil {
		return nil, fmt.Errorf("failed to select INBOX: %v", err)
	}

	// Parse start date
	since, err := time.Parse("2006-01-02", startDate)
	if err != nil {
		return nil, fmt.Errorf("invalid start date: %v", err)
	}

	// Build search criteria
	criteria := imap.NewSearchCriteria()
	criteria.Since = since
	criteria.Header.Add("From", sender)
	criteria.Header.Add("Subject", "workout")

	// Search for messages
	uids, err := c.Search(criteria)
	if err != nil {
		return nil, fmt.Errorf("failed to search: %v", err)
	}

	if len(uids) == 0 {
		return []*Email{}, nil
	}

	// Fetch messages
	seqset := new(imap.SeqSet)
	seqset.AddNum(uids...)

	messages := make(chan *imap.Message, len(uids))
	done := make(chan error, 1)
	go func() {
		done <- c.Fetch(seqset, []imap.FetchItem{imap.FetchEnvelope, imap.FetchBody + "[]"}, messages)
	}()

	var emails []*Email
	for msg := range messages {
		email, err := s.parseMessage(msg)
		if err != nil {
			continue
		}

		// Filter by Monday or Tuesday
		if isMondayOrTuesday(email.Date) {
			emails = append(emails, email)
		}
	}

	if err := <-done; err != nil {
		return nil, fmt.Errorf("failed to fetch messages: %v", err)
	}

	return emails, nil
}

// parseMessage extracts email details from IMAP message
func (s *FetchEmailsService) parseMessage(msg *imap.Message) (*Email, error) {
	if msg == nil || msg.Envelope == nil {
		return nil, fmt.Errorf("empty message")
	}

	email := &Email{
		ID:      fmt.Sprintf("%d", msg.Uid),
		Subject: msg.Envelope.Subject,
		Date:    msg.Envelope.Date,
	}

	if len(msg.Envelope.From) > 0 {
		email.From = msg.Envelope.From[0].Address()
	}
	if len(msg.Envelope.To) > 0 {
		email.To = msg.Envelope.To[0].Address()
	}

	// Extract body
	for _, literal := range msg.Body {
		if literal == nil {
			continue
		}

		mr, err := mail.CreateReader(literal)
		if err != nil {
			continue
		}

		for {
			p, err := mr.NextPart()
			if err == io.EOF {
				break
			}
			if err != nil {
				break
			}

			switch h := p.Header.(type) {
			case *mail.InlineHeader:
				b, _ := io.ReadAll(p.Body)
				contentType, _, _ := h.ContentType()
				if strings.HasPrefix(contentType, "text/plain") {
					email.Body = string(b)
				} else if strings.HasPrefix(contentType, "text/html") {
					email.BodyHTML = string(b)
				}
			}
		}
	}

	return email, nil
}

// Helper to check if date is Monday or Tuesday
func isMondayOrTuesday(t time.Time) bool {
	weekday := t.Weekday()
	return weekday == time.Monday || weekday == time.Tuesday
}
