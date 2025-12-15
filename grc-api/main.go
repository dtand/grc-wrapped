package main

import (
	"log"
	"net/http"

	"github.com/grcwrapped/grcapi/config"
	"github.com/grcwrapped/grcapi/internal/api"
	"github.com/grcwrapped/grcapi/internal/db"
	"github.com/grcwrapped/grcapi/internal/service"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"
)

func main() {
	// Load config
	cfg := config.LoadConfig()

	// Initialize DB
	database, err := db.NewDB(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer database.Close()

	// Initialize services
	fetchEmailsSvc := service.NewFetchEmailsService(cfg)

	// Initialize athlete matcher service
	athleteMatcherSvc := service.NewAthleteMatcherService(database)

	// Initialize LLM parser service with prompt template
	llmParserSvc, err := service.NewLLMParserService(
		cfg.AnthropicAPIKey,
		"resources/prompts/email_parser_prompt.txt",
		athleteMatcherSvc,
	)
	if err != nil {
		log.Fatalf("Failed to initialize LLM parser service: %v", err)
	}

	syncEmailSvc := service.NewSyncEmailService(database, cfg, fetchEmailsSvc, llmParserSvc, athleteMatcherSvc)

	// Initialize handlers
	syncEmailsHandler := api.NewSyncEmailsHandler(cfg.AdminAPIKey, syncEmailSvc)
	athletesHandler := api.NewAthletesHandler(database)
	racesHandler := api.NewRacesHandler(database)
	raceResultsHandler := api.NewRaceResultsHandler(database)
	workoutsHandler := api.NewWorkoutsHandler(database)
	athleteNicknamesHandler := api.NewAthleteNicknamesHandler(database)
	reviewFlagsHandler := api.NewReviewFlagsHandler(database, cfg.AdminAPIKey)
	emailsHandler := api.NewEmailsHandler(database, cfg.AdminAPIKey)
	yearlyStatsHandler := api.NewYearlyStatsHandler(database)

	r := chi.NewRouter()

	// CORS middleware
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   cfg.AllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	r.Post("/api/v1/sync_emails", syncEmailsHandler.ServeHTTP)
	r.Get("/api/v1/yearly_stats", yearlyStatsHandler.ServeHTTP)
	r.Route("/api/v1/athletes", func(r chi.Router) {
		r.Get("/", athletesHandler.ServeHTTP)
		r.Post("/", athletesHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", athletesHandler.ServeHTTP)
			r.Get("/details", athletesHandler.ServeHTTP)
			r.Put("/", athletesHandler.ServeHTTP)
			r.Delete("/", athletesHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/races", func(r chi.Router) {
		r.Get("/", racesHandler.ServeHTTP)
		r.Post("/", racesHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", racesHandler.ServeHTTP)
			r.Put("/", racesHandler.ServeHTTP)
			r.Delete("/", racesHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/race_results", func(r chi.Router) {
		r.Get("/", raceResultsHandler.ServeHTTP)
		r.Post("/", raceResultsHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", raceResultsHandler.ServeHTTP)
			r.Put("/", raceResultsHandler.ServeHTTP)
			r.Delete("/", raceResultsHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/workouts", func(r chi.Router) {
		r.Get("/", workoutsHandler.ServeHTTP)
		r.Post("/", workoutsHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", workoutsHandler.ServeHTTP)
			r.Put("/", workoutsHandler.ServeHTTP)
			r.Delete("/", workoutsHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/athlete_nicknames", func(r chi.Router) {
		r.Get("/", athleteNicknamesHandler.ServeHTTP)
		r.Post("/", athleteNicknamesHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", athleteNicknamesHandler.ServeHTTP)
			r.Put("/", athleteNicknamesHandler.ServeHTTP)
			r.Delete("/", athleteNicknamesHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/review_flags", func(r chi.Router) {
		r.Get("/", reviewFlagsHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", reviewFlagsHandler.ServeHTTP)
			r.Put("/resolve", reviewFlagsHandler.ServeHTTP)
		})
	})
	r.Route("/api/v1/emails", func(r chi.Router) {
		r.Get("/", emailsHandler.ServeHTTP)
		r.Route("/{id}", func(r chi.Router) {
			r.Get("/", emailsHandler.ServeHTTP)
			r.Get("/details", emailsHandler.ServeHTTP)
		})
	})

	log.Fatal(http.ListenAndServe(":"+cfg.ServerPort, r))
}
