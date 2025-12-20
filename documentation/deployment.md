# Deployment Guide

This document describes the deployment process for the GRC Running Club application (API and frontend).

## Prerequisites

- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed
- Git repository with two Heroku remotes configured:
  - `heroku` → `https://git.heroku.com/grc-api-backend.git` (API)
  - `heroku-frontend` → `https://git.heroku.com/grc-app-frontend.git` (Frontend)

## Architecture Overview

- **API Backend**: Go application deployed using Go buildpack to `grc-api-backend`
- **Frontend**: React/Vite application with Nginx deployed to `grc-app-frontend`
- **Database**: PostgreSQL on Heroku (attached to API backend)
- **Deployment Method**: 
  - API: Go Buildpack (heroku/go)
  - Frontend: Node.js Buildpack + Nginx
- **Stack**: heroku-24

## API Deployment (grc-api)

The API uses Heroku's Go buildpack for automatic compilation and deployment.

### Steps

1. **Navigate to workspace root:**
   ```bash
   cd /Users/danielanderson/Desktop/Projects/grc-wrapped
   ```

2. **Commit your changes:**
   ```bash
   git add grc-api/
   git commit -m "Description of changes"
   ```

3. **Deploy using git subtree:**
   ```bash
   git subtree push --prefix grc-api heroku main
   ```
   
   This command:
   - Pushes only the `grc-api/` subdirectory to Heroku
   - Heroku detects Go project via `go.mod`
   - Buildpack compiles the Go binary to `bin/grcapi`
   - Procfile starts the binary

4. **Verify deployment:**
   ```bash
   heroku logs --tail --app grc-api-backend
   ```

5. **Check API health:**
   ```bash
   curl https://grc-api-backend-f7a3149f8225.herokuapp.com/api/v1/yearly_stats
   ```

### Configuration Files

- `go.mod` / `go.sum` - Go module dependencies
- `Procfile` - Process definition:
  ```
  web: bin/grcapi
  ```
- Stack: heroku-24 with heroku/go buildpack

## Frontend Deployment (grc-app)

The frontend uses Node.js buildpack and Nginx to serve the built static files.

### Steps

1. **Navigate to workspace root:**
   ```bash
   cd /Users/danielanderson/Desktop/Projects/grc-wrapped
   ```

2. **Use git subtree to push only grc-app directory:**
   ```bash
   git subtree push --prefix grc-app heroku-frontend main
   ```
   
   This is necessary because the Heroku app expects `package.json` at the root, but our monorepo structure has it in `grc-app/`.

3. **Monitor deployment:**
   ```bash
   heroku logs --tail --app grc-app-frontend
   ```

### What Happens During Build

1. Heroku detects Node.js app from `package.json`
2. Installs dependencies: `npm install`
3. Runs build script: `npm run build` (TypeScript compilation + Vite build)
4. Nginx buildpack serves static files from `dist/`

### Configuration Files

- `package.json` - Contains build scripts
- `Procfile` - Defines web process (Nginx)
- `config/nginx.conf.erb` - Nginx configuration for SPA routing

## Database Migrations

When schema changes are needed:

### 1. Write Migration SQL

Create a migration file with:
```sql
-- Add new column
ALTER TABLE table_name ADD COLUMN column_name TYPE;

-- Update existing data
UPDATE table_name SET column_name = 'value' WHERE condition;

-- Backfill from related tables
UPDATE table1 t1
SET column_name = t2.column_name
FROM table2 t2
WHERE t1.foreign_key = t2.id;
```

### 2. Connect to Production Database

```bash
heroku pg:psql --app grc-api-backend
```

### 3. Run Migration

Execute SQL statements directly in psql session, or pipe from file:
```bash
heroku pg:psql --app grc-api-backend < migration.sql
```

### 4. Verify Migration

```sql
-- Check column exists
\d table_name

-- Count affected rows
SELECT COUNT(*) FROM table_name WHERE column_name IS NOT NULL;
```

### 5. Deploy Code Changes

After database migration completes, deploy API code that uses the new schema:
```bash
cd grc-api
heroku container:push web --app grc-api-backend
heroku container:release web --app grc-api-backend
```

## Full Deployment Workflow

When making changes that affect both API and UI:

### 1. Commit Changes
```bash
# From workspace root
git add grc-api/ grc-app/
git commit -m "Description of changes"
```

### 2. Run Database Migration (if needed)
```bash
heroku pg:psql --app grc-api-backend < migration.sql
```

### 3. Deploy API
```bash
cd /Users/danielanderson/Desktop/Projects/grc-wrapped
git subtree push --prefix grc-api heroku main
```

### 4. Deploy Frontend
```bash
cd ..  # Back to workspace root
git subtree push --prefix grc-app heroku-frontend main
```

### 5. Verify Deployment
```bash
# Check API
curl https://grc-api-backend-f7a3149f8225.herokuapp.com/health

# Check Frontend
open https://grc-app-frontend-8839ec2851e0.herokuapp.com

# Monitor logs
heroku logs --tail --app grc-api-backend
heroku logs --tail --app grc-app-frontend
```

## Troubleshooting

### API Container Build Issues

**Error**: Binary not found during startup
- **Solution**: Ensure Procfile references correct binary name (should match module name from go.mod)
- **Check**: `heroku logs` for "No such file or directory" errors

**Error**: "push rejected" when using git push
- **Solution**: Use `git subtree push --prefix grc-api heroku main` from workspace root, not from grc-api directory

**Error**: Build fails with module errors
- **Solution**: Ensure `go.mod` and `go.sum` are up to date: `go mod tidy`

### Frontend Build Issues

**Error**: "App not compatible with buildpack: package.json not found"
- **Solution**: Must use `git subtree push --prefix grc-app` from workspace root, not `git push` from grc-app directory

**Error**: Build succeeds but app shows blank page
- **Check**: Environment variables are set correctly: `VITE_API_URL`, `VITE_ADMIN_API_KEY`
- **Verify**: Nginx config properly serves SPA routes

### Database Issues

**Error**: "database unstable" during credential rotation
- **Solution**: Wait for database to stabilize before rotating credentials

**Error**: "column does not exist" after deployment
- **Solution**: Ensure migration runs BEFORE deploying code that uses new schema

## Rollback Procedure

### API Rollback
```bash
# View release history
heroku releases --app grc-api-backend

# Rollback to previous release
heroku rollback v<version> --app grc-api-backend
```

### Frontend Rollback
```bash
# View release history
heroku releases --app grc-app-frontend

# Rollback to previous release
heroku rollback v<version> --app grc-app-frontend
```

### Database Rollback
Database changes are permanent. To rollback:
1. Write reverse migration SQL
2. Run reverse migration
3. Rollback application code

## Environment Variables

### API (grc-api-backend)
```bash
heroku config --app grc-api-backend

# Key variables:
# - DATABASE_URL (automatically set by Heroku Postgres)
# - ANTHROPIC_API_KEY (for LLM parsing)
# - GMAIL_APP_PASSWORD (for email sync)
```

### Frontend (grc-app-frontend)
```bash
heroku config --app grc-app-frontend

# Key variables:
# - VITE_API_URL (backend API URL)
# - VITE_ADMIN_API_KEY (for admin endpoints)
```

### Updating Environment Variables
```bash
heroku config:set VARIABLE_NAME=value --app app-name
```

## Monitoring

### View Logs
```bash
# Real-time logs
heroku logs --tail --app grc-api-backend
heroku logs --tail --app grc-app-frontend

# Last 500 lines
heroku logs -n 500 --app grc-api-backend
```

### Check App Status
```bash
heroku ps --app grc-api-backend
heroku ps --app grc-app-frontend
```

### Database Metrics
```bash
heroku pg:info --app grc-api-backend
```

## Useful Commands

```bash
# Restart app
heroku restart --app grc-api-backend

# Run one-off command
heroku run bash --app grc-api-backend

# Open app in browser
heroku open --app grc-app-frontend

# Check buildpacks
heroku buildpacks --app grc-app-frontend

# Check stack
heroku stack --app grc-api-backend
```
