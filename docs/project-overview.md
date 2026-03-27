# Project Overview

## Executive Summary

Full Stack FastAPI Template is a production-ready monorepo template for building modern web applications. It combines a Python/FastAPI backend with a React/TypeScript frontend, orchestrated via Docker Compose with Traefik as reverse proxy.

## Technology Stack Summary

| Category | Technology | Version |
|----------|-----------|---------|
| **Backend Framework** | FastAPI | 0.114.2+ |
| **Backend Language** | Python | 3.10 |
| **ORM** | SQLModel | 0.0.21+ |
| **Database** | PostgreSQL | 18 |
| **Migrations** | Alembic | 1.12.1+ |
| **Frontend Framework** | React | 19.1.1 |
| **Frontend Language** | TypeScript | 5.9.3 |
| **Build Tool** | Vite | 7.3.0 |
| **Router** | TanStack Router | 1.163.3 |
| **State Management** | TanStack Query | 5.90.21 |
| **Styling** | Tailwind CSS | 4.2.1 |
| **UI Components** | shadcn/ui | Radix primitives |
| **Package Manager (BE)** | uv | 0.9.26 |
| **Package Manager (FE)** | Bun | 1.x |
| **Linter (BE)** | Ruff | 0.2.2+ |
| **Linter (FE)** | Biome | 2.3.14 |
| **Type Checker** | MyPy | 1.8.0+ (strict) |
| **E2E Testing** | Playwright | 1.58.2 |
| **Reverse Proxy** | Traefik | 3.6 |
| **Containerization** | Docker Compose | - |

## Architecture Type

**Full-Stack Web Application** with:
- REST API backend (FastAPI)
- SPA frontend (React)
- PostgreSQL database
- JWT authentication
- Docker Compose orchestration

## Repository Structure

```
full-stack-fastapi-template/
├── backend/              # Python FastAPI backend
│   ├── app/             # Application code
│   │   ├── api/         # API routes and dependencies
│   │   ├── core/        # Config, security, DB
│   │   ├── alembic/     # Database migrations
│   │   ├── models.py    # SQLModel definitions
│   │   └── crud.py      # Database operations
│   └── tests/           # Pytest suite
├── frontend/            # React + TypeScript frontend
│   ├── src/            # Source code
│   │   ├── components/ # React components (shadcn/ui)
│   │   ├── routes/     # TanStack file-based routes
│   │   ├── hooks/      # Custom React hooks
│   │   └── client/     # Auto-generated OpenAPI client
│   └── tests/          # Playwright E2E tests
├── scripts/            # Project-level automation
├── compose.yml         # Docker Compose (production)
├── compose.override.yml # Docker Compose (dev overrides)
└── docs/               # Project documentation (this)
```

## Key Features

- **Authentication:** JWT-based with OAuth2 password flow
- **Authorization:** Role-based (superuser vs regular user)
- **API Documentation:** Auto-generated Swagger UI at `/docs`
- **Database:** PostgreSQL with Alembic migrations
- **Email:** SMTP integration with MJML templates
- **Monitoring:** Sentry integration
- **CI/CD:** GitHub Actions with 12 workflows
- **Deployment:** Docker Compose with Traefik (auto HTTPS)

## Links

- [Source Tree Analysis](./source-tree-analysis.md)
- [Architecture - Backend](./architecture-backend.md)
- [Architecture - Frontend](./architecture-frontend.md)
- [Development Guide](./development-guide-backend.md)
- [Deployment Guide](./deployment-guide.md)
