# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-27
**Project:** Full Stack FastAPI Template
**Stack:** FastAPI + React + TypeScript + PostgreSQL + Docker

## OVERVIEW

Monorepo full-stack template with Python/FastAPI backend and React/TypeScript frontend. Uses Docker Compose for orchestration, SQLModel for ORM, TanStack Router for routing, shadcn/ui for components.

## STRUCTURE

```
.
├── backend/              # Python FastAPI backend
│   ├── app/             # Application code (models, routes, crud)
│   ├── tests/           # Pytest tests
│   └── scripts/         # Build/test scripts
├── frontend/            # React + TypeScript frontend
│   ├── src/            # Source code
│   │   ├── components/ # React components (shadcn/ui)
│   │   ├── routes/     # TanStack Router file-based routes
│   │   ├── hooks/      # Custom React hooks
│   │   └── client/     # Auto-generated OpenAPI client
│   └── tests/          # Playwright E2E tests
├── scripts/            # Project-level automation
├── compose.yml         # Docker Compose (production)
└── compose.override.yml # Docker Compose (dev overrides)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add API endpoint | `backend/app/api/routes/` | Create route file, register in `api/main.py` |
| Add DB model | `backend/app/models.py` | SQLModel, then run alembic migration |
| Add DB operation | `backend/app/crud.py` | CRUD functions |
| Add React component | `frontend/src/components/` | Organize by feature subdirectory |
| Add new page/route | `frontend/src/routes/` | TanStack file-based routing |
| Add custom hook | `frontend/src/hooks/` | Prefix with `use` |
| Modify API client | DON'T | Auto-generated, run `generate-client.sh` |
| Change auth logic | `backend/app/core/security.py` | JWT + password hashing |
| Change app config | `backend/app/core/config.py` | Pydantic settings from env |
| Database migrations | `backend/app/alembic/versions/` | Alembic auto-generated |
| Email templates | `backend/app/email-templates/src/` | MJML source, build to HTML |
| UI components | `frontend/src/components/ui/` | shadcn/ui (generated) |
| E2E tests | `frontend/tests/` | Playwright spec files |

## CODE MAP

### Backend Key Symbols

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `app` | FastAPI | `backend/app/main.py` | Main application instance |
| `api_router` | APIRouter | `backend/app/api/main.py` | Aggregates all route modules |
| `get_db` | Generator | `backend/app/api/deps.py` | DB session dependency |
| `get_current_user` | Function | `backend/app/api/deps.py` | Auth dependency |
| `Settings` | Class | `backend/app/core/config.py` | App configuration |
| `User` | SQLModel | `backend/app/models.py` | User model |
| `Item` | SQLModel | `backend/app/models.py` | Item model |

### Frontend Key Symbols

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `main.tsx` | Entry | `frontend/src/main.tsx` | React root render |
| `routeTree` | Generated | `frontend/src/routeTree.gen.ts` | TanStack route tree |
| `useAuth` | Hook | `frontend/src/hooks/useAuth.ts` | Auth state management |
| `useCustomToast` | Hook | `frontend/src/hooks/useCustomToast.ts` | Toast notifications |
| `User` | Component | `frontend/src/components/Sidebar/User.tsx` | User display |
| `ItemsTable` | Component | `frontend/src/components/Items/ItemsTable.tsx` | Items list |

## CONVENTIONS

### Backend (Python)
- **Linter:** Ruff (not flake8/pylint)
- **Formatter:** Ruff (not black)
- **Type checker:** mypy (strict mode)
- **ORM:** SQLModel (not raw SQLAlchemy)
- **Migrations:** Alembic (auto-generate)
- **Package manager:** uv (not pip/poetry)

### Frontend (TypeScript)
- **Linter/Formatter:** Biome (not ESLint+Prettier)
- **Router:** TanStack Router file-based (not React Router)
- **State:** TanStack Query (not Redux/Zustand)
- **Components:** shadcn/ui (not Material UI/Chakra)
- **Styling:** Tailwind CSS (not CSS modules/styled-components)
- **Package manager:** Bun (not npm/yarn)

### General
- **Containerization:** Docker Compose (not standalone Docker)
- **Reverse proxy:** Traefik (not Nginx)
- **Email testing:** Mailcatcher (not Mailhog)

## ANTI-PATTERNS (THIS PROJECT)

### NEVER DO
- Use `as any` or `@ts-ignore` in new code (existing instances in generated client only)
- Edit `frontend/src/client/` directly (auto-generated, use `generate-client.sh`)
- Use `print()` in backend (use logging)
- Skip type annotations in Python (mypy strict mode)
- Use ESLint/Prettier for frontend (use Biome)
- Use pip/poetry for backend (use uv)
- Use npm/yarn for frontend (use bun)

### ALWAYS DO
- Run `alembic revision --autogenerate` after model changes
- Run `generate-client.sh` after API schema changes
- Use `QueryClient` for data fetching (not fetch/axios directly)
- Use `data-testid` attributes for Playwright tests
- Follow existing directory structure for new features

## UNIQUE STYLES

- **Generated client committed:** `frontend/src/client/` is in source control (unusual)
- **Copier template:** Project supports regeneration via Copier
- **Email build step:** MJML templates compiled to HTML
- **Dual lock files:** `uv.lock` + `bun.lock` at root
- **Pre-commit SDK generation:** Auto-regenerates frontend client on backend changes

## COMMANDS

```bash
# Development
docker compose watch              # Full stack with live reload

# Backend
cd backend && uv sync            # Install dependencies
fastapi dev app/main.py          # Dev server
bash ./scripts/test.sh           # Run tests
alembic revision --autogenerate -m "desc"  # New migration
alembic upgrade head             # Apply migrations

# Frontend
cd frontend && bun install       # Install dependencies
bun run dev                      # Dev server
bunx playwright test             # E2E tests
bun run lint                     # Lint with Biome

# Code Generation
bash ./scripts/generate-client.sh  # Regenerate TS client from OpenAPI
```

## NOTES

- Backend runs on port 8000, frontend on 5173 (dev) / 80 (prod)
- API prefix: `/api/v1`
- Swagger UI: `/docs`, ReDoc: `/redoc`
- Database: PostgreSQL 18
- First superuser created via `initial_data.py`
- Test user email: `settings.EMAIL_TEST_USER`
