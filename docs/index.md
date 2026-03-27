# Project Documentation Index

## Project Overview

- **Type:** Monorepo with 2 parts (backend + frontend)
- **Primary Languages:** Python 3.10 (backend), TypeScript (frontend)
- **Architecture:** Full-stack web application with REST API

## Quick Reference

### Backend (FastAPI)

- **Type:** REST API Backend
- **Tech Stack:** Python 3.10, FastAPI 0.114.2+, SQLModel, PostgreSQL 18
- **Root:** `backend/`
- **Entry Point:** `backend/app/main.py`
- **Architecture Pattern:** Layered (Routes → CRUD → Models)

### Frontend (React)

- **Type:** SPA Web Application
- **Tech Stack:** React 19, TypeScript, Vite 7.3, TanStack Router/Query, Tailwind CSS 4.2
- **Root:** `frontend/`
- **Entry Point:** `frontend/src/main.tsx`
- **Architecture Pattern:** Component-based with file-based routing

## Generated Documentation

- [Project Overview](./project-overview.md)
- [Architecture - Backend](./architecture-backend.md)
- [Architecture - Frontend](./architecture-frontend.md)
- [Source Tree Analysis](./source-tree-analysis.md)
- [Development Guide - Backend](./development-guide-backend.md)
- [Development Guide - Frontend](./development-guide-frontend.md)
- [Deployment Guide](./deployment-guide.md)
- [API Contracts - Backend](./api-contracts-backend.md)
- [Data Models - Backend](./data-models-backend.md)
- [Component Inventory - Frontend](./component-inventory-frontend.md)
- [Integration Architecture](./integration-architecture.md)

## Existing Documentation

- [README.md](../README.md) - Main project documentation
- [AGENTS.md](../AGENTS.md) - AI agent knowledge base
- [backend/AGENTS.md](../backend/AGENTS.md) - Backend agent conventions
- [frontend/AGENTS.md](../frontend/AGENTS.md) - Frontend agent conventions
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [development.md](../development.md) - Development guide
- [deployment.md](../deployment.md) - Deployment guide
- [SECURITY.md](../SECURITY.md) - Security policy
- [CLAUDE.md](../CLAUDE.md) - Claude Code CLI guidance
- [backend/README.md](../backend/README.md) - Backend documentation
- [frontend/README.md](../frontend/README.md) - Frontend documentation

## Getting Started

### Quick Start (Docker)

```bash
docker compose watch
```

- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Traefik Dashboard: http://localhost:8090

### Backend Development

```bash
cd backend
uv sync
source .venv/bin/activate
fastapi dev app/main.py
```

### Frontend Development

```bash
cd frontend
bun install
bun run dev
```

### Running Tests

```bash
# Backend tests
cd backend && bash ./scripts/test.sh

# Frontend E2E tests
cd frontend && bunx playwright test
```
