# GRC Running Club API

A RESTful API for managing running club data, built with Go, chi, and PostgreSQL.

## Features
- Manage athletes, races, race results, workouts (with groups & segments)
- Synchronize data from emails

## Structure
- `cmd/server` — Entrypoint
- `internal/api` — HTTP handlers
- `internal/models` — DB models
- `internal/db` — DB connection
- `internal/email` — Email parsing
- `internal/service` — Business logic
- `pkg/middleware` — Middleware
- `config` — Configuration

## Getting Started
1. Configure `config/config.yaml`
2. Run `go mod tidy`
3. Start server: `go run cmd/server/main.go`
