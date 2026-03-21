# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Docker Compose (Full Stack)
```bash
# Start development stack with live reload
docker compose watch

# View logs
docker compose logs
docker compose logs backend  # specific service

# Stop services
docker compose stop frontend
docker compose down -v  # clean slate with volumes
```

### Backend Development
```bash
cd backend

# Install dependencies
uv sync

# Run development server with hot reload
fastapi dev app/main.py

# Run tests
bash ./scripts/test.sh

# Run tests (if stack is already up)
docker compose exec backend bash scripts/tests-start.sh
docker compose exec backend bash scripts/tests-start.sh -x  # stop on first error

# Run a single test
docker compose exec backend bash -c "pytest backend/tests/path/to/test_file.py::test_name -xvs"

# Database migrations (Alembic)
alembic revision --autogenerate -m "Description"
alembic upgrade head

# Linting (pre-commit hooks)
cd backend && uv run prek run --all-files
```

### Frontend Development
```bash
cd frontend

# Install dependencies
bun install

# Run development server
bun run dev  # from root: bun run dev (uses workspace)

# Linting
bun run lint

# Testing (Playwright)
docker compose up -d --wait backend
bunx playwright test
bunx playwright test --ui  # interactive UI mode
```

### Code Generation
```bash
# Generate TypeScript client from OpenAPI schema
bash ./scripts/generate-client.sh
```

## Architecture Overview

### Backend (FastAPI + SQLModel)
- **Entry point**: `backend/app/main.py` - FastAPI app initialization, CORS, routes
- **Models**: `backend/app/models.py` - SQLModel models (User, Item) with Pydantic schemas for API
- **CRUD**: `backend/app/crud.py` - Database operations
- **Routes**: `backend/app/api/routes/` - API endpoints (users, items, login, utils, private)
- **Core**: `backend/app/core/` - Config, security (JWT/password hashing), database setup
- **Migrations**: `backend/app/alembic/` - Database migrations
- **API prefix**: `/api/v1`

### Frontend (React + Vite + TypeScript + TanStack)
- **Generated client**: `frontend/src/client/` - Auto-generated from OpenAPI spec (`sdk.gen.ts`, `schemas.gen.ts`, `types.gen.ts`)
- **Routes**: `frontend/src/routes/` - TanStack Router file-based routing
- **Components**: `frontend/src/components/` - Organized by feature (Admin, Common, Items, Sidebar, UserSettings)
- **UI components**: `frontend/src/components/ui/` - shadcn/ui components
- **Hooks**: `frontend/src/hooks/` - Custom React hooks (useAuth, useCustomToast, etc.)
- **Routing**: `frontend/src/routeTree.gen.ts` - Generated route tree

### Database
- **ORM**: SQLModel (SQLAlchemy + Pydantic)
- **Migrations**: Alembic with auto-generated revisions
- **Models**: User (with items relationship), Item (owned by user)

### Key Files
- `compose.yml` - Main Docker Compose configuration
- `compose.override.yml` - Development overrides (volume mounts, live reload)
- `.env` - Environment variables (secrets, domain, database credentials)
- `backend/app/core/config.py` - Application settings from environment

### Development URLs
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Adminer (DB): http://localhost:8080
- Mailcatcher: http://localhost:1080
- Traefik: http://localhost:8090
