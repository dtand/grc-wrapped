# Running Club API Specification

## Athletes
- `GET /athletes` — List all athletes.
  - **Query Parameters:**
    - `name` — Filter by athlete name (partial match)
    - `gender` — Filter by gender
    - `active` — Filter by active status (`true`/`false`)
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /athletes/{id}` — Get a specific athlete by ID.
- `GET /athletes/{id}/details` — Get comprehensive athlete details including all race performances with race information.
  - **Response:**
    ```json
    {
      "athlete": {
        "id": 1,
        "name": "John Doe",
        "gender": "M",
        "active": true,
        "website_url": "https://example.com"
      },
      "race_performances": [
        {
          "race_result": {
            "id": 1,
            "race_id": 1,
            "athlete_id": 1,
            "unknown_athlete_name": "",
            "time": "20:30",
            "pr_improvement": "-2:15",
            "notes": "Great race!",
            "position": 5,
            "is_pr": true,
            "tags": ["season_best", "course_record"],
            "flagged": false,
            "flag_reason": "",
            "email_id": 1
          },
          "race": {
            "id": 1,
            "name": "Winter Classic 5K",
            "date": "2025-01-15",
            "year": "2025",
            "distance": "5k",
            "notes": "Annual winter race",
            "email_id": 1
          }
        }
      ],
      "nicknames": [
        {
          "id": 1,
          "athlete_id": 1,
          "nickname": "Johnny"
        }
      ]
    }
    ```
- `POST /athletes` — Create a new athlete.
  - **Body:**
    ```json
    {
      "name": "string",
      "gender": "string",
      "active": true
    }
    ```
- `PUT /athletes/{id}` — Update athlete info.
  - **Body:** Same as POST.
- `DELETE /athletes/{id}` — Delete an athlete.

## Races
- `GET /races` — List all races.
  - **Query Parameters:**
    - `name` — Filter by race name (partial match)
    - `date` — Filter by race date (exact or range, e.g., `>=2025-01-01`)
    - `distance` — Filter by race distance (e.g., "5k", "10k", "half marathon")
    - `email_id` — Filter by source email
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /races/{id}` — Get a specific race by ID.
- `POST /races` — Create a new race.
  - **Body:**
    ```json
    {
      "name": "string",
      "date": "YYYY-MM-DD",
      "distance": "string",
      "notes": "string",
      "email_id": 1
    }
    ```
- `PUT /races/{id}` — Update race info.
  - **Body:** Same as POST.
- `DELETE /races/{id}` — Delete a race

## Race Results
- `GET /race_results` — List all race results.
  - **Query Parameters:**
    - `athlete_id` — Filter by athlete
    - `race_id` — Filter by race
    - `is_pr` — Filter by PR status (`true`/`false`)
    - `tags` — Filter by tags (single or multiple)
    - `position` — Filter by position (exact or range)
    - `flagged` — Filter by flagged status (`true`/`false`)
    - `email_id` — Filter by source email
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /race_results/{id}` — Get a specific race result by ID.
- `POST /race_results` — Create a new race result.
  - **Body:**
    ```json
    {
      "race_id": 1,
      "athlete_id": 1,
      "unknown_athlete_name": "string",
      "time": "string",
      "pr_improvement": "string",
      "notes": "string",
      "position": 1,
      "is_pr": true,
      "tags": ["string"],
      "flagged": false,
      "flag_reason": "string",
      "email_id": 1
    }
    ```
- `PUT /race_results/{id}` — Update race result.
  - **Body:** Same as POST.
- `DELETE /race_results/{id}` — Delete a race result

## Workouts (with Groups & Segments)
- `GET /workouts` — List all workouts.
  - **Query Parameters:**
    - `date` — Filter by workout date (exact or range)
    - `location` — Filter by location (partial match)
    - `email_id` — Filter by source email
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /workouts/{id}` — Get a specific workout, including its groups and segments.
- `POST /workouts` — Create a new workout, including nested groups and segments.
  - **Body:**
    ```json
    {
      "date": "YYYY-MM-DD",
      "location": "string",
      "start_time": "HH:MM:SS",
      "coach_notes": "string",
      "email_id": 1,
      "groups": [
        {
          "group_name": "string",
          "description": "string",
          "segments": [
            {
              "segment_type": "string",
              "repetitions": 4,
              "rest": "2:00",
              "targets": "72, 71, 70, 69"
            }
          ]
        }
      ]
    }
    ```
- `PUT /workouts/{id}` — Update workout, including nested groups and segments.
  - **Body:** Same as POST.
- `DELETE /workouts/{id}` — Delete a workout and all associated groups and segments.

## Yearly stats
- `GET /yearly_stats` — Get yearly statistics for the club and athletes.
  - **Response:**
    ```json
    {
      "personal_bests": 12,
      "races_competed": 8,
      "club_records": 2,
      "popular_races": [
        { "race": "Winter Classic 5K", "participants": 24 },
        { "race": "Spring Sprint 10K", "participants": 18 }
      ]
    }
    ```
  - **Fields:**
    - `personal_bests` (int): Number of personal bests achieved by club members this year
    - `races_competed` (int): Number of races club members have competed in this year
    - `club_records` (int): Number of club records broken this year
    - `popular_races` (array): List of most popular races with participant counts
      - `race` (string): Race name
      - `participants` (int): Number of club participants in the race

## Athlete Nicknames
- `GET /athlete_nicknames` — List all athlete nicknames.
  - **Query Parameters:**
    - `athlete_id` — Filter by athlete ID
    - `nickname` — Filter by nickname (partial match)
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /athlete_nicknames/{id}` — Get a specific nickname by ID.
- `POST /athlete_nicknames` — Create a new nickname for an athlete.
  - **Body:**
    ```json
    {
      "athlete_id": 1,
      "nickname": "string"
    }
    ```
- `PUT /athlete_nicknames/{id}` — Update a nickname.
  - **Body:** Same as POST.
- `DELETE /athlete_nicknames/{id}` — Delete a nickname.

## Emails
- `GET /emails` — List all processed emails.
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
  - **Query Parameters:**
    - `title` — Filter by email title (partial match)
    - `sender` — Filter by sender email
    - `recipient` — Filter by recipient email
    - `date` — Filter by email date (exact or range, e.g., `>=2025-01-01`)
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /emails/{id}` — Get a specific email by ID (includes full body content).
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
- `GET /emails/{id}/details` — Get comprehensive email details including all associated parsed data.
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
  - **Response:**
    ```json
    {
      "email": {
        "id": 1,
        "title": "Race Results - Winter Classic 5K",
        "body": "Full email content...",
        "date": "2025-01-15",
        "sender": "coach@example.com",
        "recipient": "team@example.com"
      },
      "athletes": [
        {
          "id": 1,
          "name": "John Doe",
          "gender": "M",
          "active": true,
          "website_url": "https://example.com"
        }
      ],
      "races": [
        {
          "id": 1,
          "name": "Winter Classic 5K",
          "date": "2025-01-15",
          "distance": "5k",
          "notes": "Annual winter race",
          "email_id": 1
        }
      ],
      "race_results": [
        {
          "id": 1,
          "race_id": 1,
          "athlete_id": 1,
          "unknown_athlete_name": "",
          "time": "20:30",
          "pr_improvement": "-2:15",
          "notes": "Great race!",
          "position": 5,
          "is_pr": true,
          "tags": ["season_best", "course_record"],
          "flagged": false,
          "flag_reason": "",
          "email_id": 1,
          "date_recorded": "2025-01-15"
        }
      ],
      "workouts": [
        {
          "id": 1,
          "date": "2025-01-14",
          "location": "Track",
          "start_time": "18:00",
          "coach_notes": "Easy pace workout",
          "email_id": 1
        }
      ]
    }
    ```

## Review Flags (Admin)
- `GET /review_flags` — List all review flags for items needing attention.
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
  - **Query Parameters:**
    - `resolved` — Filter by resolution status (`true`/`false`, default `false`)
    - `flag_type` — Filter by flag type (e.g., 'ambiguous_athlete', 'unknown_athlete')
    - `entity_type` — Filter by entity type (e.g., 'race_result', 'workout')
    - `email_id` — Filter by source email
    - `limit` — Limit number of results
    - `offset` — Pagination offset
- `GET /review_flags/{id}` — Get a specific review flag by ID.
- `PUT /review_flags/{id}/resolve` — Mark a review flag as resolved.
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
  - **Body:**
    ```json
    {
      "resolved_by": "string"
    }
    ```

## Synchronize Emails & Data (Admin)
- `POST /sync_emails` — Admin endpoint to fetch, parse, and populate database from emails.
  - **Security:** Requires API key in header (`Authorization: Bearer <API_KEY>`)
  - **Request Body:**
    ```json
    {
      "start_date": "YYYY-MM-DD", // Earliest email date to fetch
      "sender": "string",         // Sender email address (hard-coded criteria)
      "recipient": "string"       // Recipient email address (hard-coded criteria)
    }
    ```
  - **Process:**
    1. Pull all emails in chronological order from `start_date` matching sender/recipient criteria.
    2. For each email, extract title and body, and send to Copilot API (using provided API key) for parsing.
    3. Copilot returns parsed data in strict schema (see below for requirements).
    4. Populate database tables with parsed data.
  - **Response:**
    ```json
    {
      "emails_processed": 10,
      "records_created": {
        "athletes": 5,
        "races": 2,
        "race_results": 14,
        "workouts": 1
      },
      "errors": []
    }
    ```
  - **Output Schema Requirements:**
    - Parsed data must match the database schema for athletes, races, race_results, workouts (with nested groups/segments).
    - All required fields must be present; missing or ambiguous data should be flagged in the response errors.
    - Example output format:
      ```json
      {
        "athletes": [ ... ],
        "races": [ ... ],
        "race_results": [ ... ],
        "workouts": [ ... ]
      }
      ```
---

### Response Formats

**List Endpoints (GET /resource):**
```json
{
  "data": [
    { /* resource object */ }
  ],
  "total": 100,
  "limit": 10,
  "offset": 0
}
```

**Single Resource (GET /resource/{id}):**
```json
{
  "id": 1,
  /* other resource fields */
}
```

**Create/Update/Delete Success:**
```json
{
  "success": true,
  "id": 1  // for create operations
}
```

**Error Response:**
```json
{
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

### Authentication & Security
- **Admin Endpoints** require API key in header: `Authorization: Bearer <API_KEY>`
- **Affected endpoints:** `/sync_emails`, `/review_flags`, `/emails`
- API key is configured via `ADMIN_API_KEY` environment variable

### Data Validation & Constraints

**Required Fields:**
- `athletes.name` - Must be unique, cannot be empty
- `athletes.gender` - Must be 'M', 'F', or 'NB'
- `races.name` - Cannot be empty
- `workouts.date` - Cannot be empty
- `workout_groups.group_name` - Cannot be empty
- `workout_segments.segment_type` - Cannot be empty

**Foreign Key Constraints:**
- `athlete_nicknames.athlete_id` → `athletes.id`
- `races.email_id` → `emails.id`
- `race_results.race_id` → `races.id`
- `race_results.athlete_id` → `athletes.id` (nullable)
- `workouts.email_id` → `emails.id`
- `workout_groups.workout_id` → `workouts.id`
- `workout_segments.workout_group_id` → `workout_groups.id`

**Data Types:**
- `tags` - TEXT[] array (PostgreSQL array type)
- `gender` - ENUM: 'M', 'F', 'NB'
- `active` - BOOLEAN (default true)
- Dates use ISO format: `YYYY-MM-DD`
- Times use format: `HH:MM:SS`

### Notes
- All `POST` and `PUT` endpoints accept JSON bodies matching the table fields.
- Foreign key fields (e.g., `race_id`, `athlete_id`, `workout_id`) should be included in relevant requests.
- For filtering (e.g., results by athlete, race, or workout), use query parameters:
  - `GET /race_results?athlete_id=1`
  - `GET /workouts?date=2025-12-10`
- Workout group endpoints should allow nested segment data for creation and updates.
