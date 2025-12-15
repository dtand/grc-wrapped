# GRC Running Club API

A RESTful API for managing running club data, built with Go, chi, and PostgreSQL.

## Features
- Manage athletes, races, race results, workouts (with groups & segments)
- Track personal records (PRs) and club records
- Athlete nickname management for email parsing
- Email synchronization with LLM-powered parsing
- Review flags for ambiguous data
- Yearly statistics aggregation

## Project Structure

```
grc-api/
├── main.go                    # Application entry point & route definitions
├── config/
│   └── config.go             # Configuration management
├── internal/
│   ├── api/                  # HTTP handlers for all endpoints
│   │   ├── athletes.go
│   │   ├── races.go
│   │   ├── race_results.go
│   │   ├── workouts.go
│   │   ├── athlete_nicknames.go
│   │   ├── review_flags.go
│   │   ├── emails.go
│   │   ├── sync_emails.go
│   │   └── yearly_stats.go
│   ├── db/
│   │   └── db.go             # Database layer with all queries
│   ├── models/               # Data models
│   │   ├── athlete.go
│   │   ├── race.go
│   │   ├── race_result.go
│   │   ├── workout.go
│   │   ├── email.go
│   │   └── ...
│   └── service/              # Business logic
│       ├── sync_email_service.go
│       └── llm_parser_service.go
├── resources/
│   └── prompts/              # LLM prompts for email parsing
└── secrets/                  # API keys and credentials (gitignored)
```

## API Endpoints

Base URL: `http://localhost:8080/api/v1`

### Athletes
- `GET /athletes` - List all athletes (with pagination & filters)
  - Query params: `name`, `gender`, `active`, `limit`, `offset`
- `GET /athletes/details` - Get all athletes with race performances (bulk)
- `GET /athletes/{id}` - Get single athlete
- `GET /athletes/{id}/details` - Get athlete with race performances & nicknames
- `POST /athletes` - Create new athlete
- `PUT /athletes/{id}` - Update athlete
- `DELETE /athletes/{id}` - Delete athlete

### Races
- `GET /races` - List all races (with pagination & filters)
  - Query params: `name`, `year`, `distance`, `email_id`, `limit`, `offset`
- `GET /races/{id}` - Get single race
- `POST /races` - Create new race
- `PUT /races/{id}` - Update race
- `DELETE /races/{id}` - Delete race

### Race Results
- `GET /race_results` - List all race results (with pagination & filters)
  - Query params: `athlete_id`, `race_id`, `is_pr`, `is_club_record`, `limit`, `offset`
- `GET /race_results/{id}` - Get single race result
- `POST /race_results` - Create new race result
- `PUT /race_results/{id}` - Update race result
- `DELETE /race_results/{id}` - Delete race result

### Workouts
- `GET /workouts` - List all workouts (with pagination & filters)
  - Query params: `name`, `date`, `location`, `limit`, `offset`
- `GET /workouts/{id}` - Get single workout with groups & segments
- `POST /workouts` - Create new workout
- `PUT /workouts/{id}` - Update workout
- `DELETE /workouts/{id}` - Delete workout

### Athlete Nicknames
- `GET /athlete_nicknames` - List all nicknames (with pagination & filters)
  - Query params: `athlete_id`, `nickname`, `limit`, `offset`
- `GET /athlete_nicknames/{id}` - Get single nickname
- `POST /athlete_nicknames` - Create new nickname
- `PUT /athlete_nicknames/{id}` - Update nickname
- `DELETE /athlete_nicknames/{id}` - Delete nickname

### Review Flags
- `GET /review_flags` - List all review flags (with pagination & filters)
  - Query params: `resolved`, `limit`, `offset`
- `GET /review_flags/{id}` - Get single review flag
- `PUT /review_flags/{id}/resolve` - Resolve a review flag

### Emails
- `GET /emails` - List all emails (with pagination & filters)
  - Query params: `title`, `processed`, `limit`, `offset`
- `GET /emails/{id}` - Get single email
- `GET /emails/{id}/details` - Get email with all associated data

### Admin
- `POST /sync_emails` - Sync emails from Gmail and parse with LLM
  - Requires: `Authorization: Bearer <ADMIN_API_KEY>`
  - Body: `{ "max_results": 10, "query": "subject:..." }`

### Statistics
- `GET /yearly_stats` - Get yearly aggregated statistics
  - Returns: total races, PRs, club records, and participation timeline

## Getting Started

### Prerequisites
- Go 1.21+
- PostgreSQL 14+
- Gmail API credentials (for email sync)
- OpenAI API key (for LLM parsing)

### Setup
1. Configure database:
   ```bash
   psql -U postgres -f db/grc_running_club_schema.sql
   psql -U postgres -f db/seed_athletes.sql
   ```

2. Set up configuration:
   ```bash
   cp config/config.yaml.example config/config.yaml
   # Edit config/config.yaml with your settings
   ```

3. Add secrets:
   ```bash
   # Add your API keys to secrets/ directory
   echo "your-openai-key" > secrets/openai_api_key.txt
   echo "your-admin-key" > secrets/admin_api_key.txt
   # Add Gmail credentials.json to secrets/
   ```

4. Install dependencies:
   ```bash
   go mod tidy
   ```

5. Run the server:
   ```bash
   go run main.go
   ```

The API will be available at `http://localhost:8080`

## Environment Variables
- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `DB_NAME` - Database name
- `SERVER_PORT` - API server port (default: 8080)

## Development
- All handlers support pagination with `limit` and `offset` query parameters
- Default pagination: `limit=50`, `offset=0`
- CORS is enabled for `localhost:5173` and `localhost:3000`
- All timestamps are in UTC
- Boolean fields support `true`/`false` query parameter values
# Heroku deployment
