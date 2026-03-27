# AGENTS.md - Backend

## OVERVIEW

Python/FastAPI backend with SQLModel ORM, Alembic migrations, JWT auth.

## STRUCTURE

```
backend/
├── app/
│   ├── api/routes/       # Login, users, items, utils, private
│   ├── core/             # Config, security, db
│   ├── alembic/          # Migrations
│   ├── main.py           # FastAPI app entry
│   ├── models.py         # SQLModel definitions
│   ├── crud.py           # Database operations
│   └── api/deps.py       # Dependency injection
├── tests/                # Pytest suite
└── pyproject.toml        # Ruff + mypy strict
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add API endpoint | `app/api/routes/` | Create route, register in `api/main.py` |
| Add DB model | `app/models.py` | SQLModel, then `alembic revision --autogenerate` |
| Add DB operation | `app/crud.py` | CRUD functions |
| Auth logic | `app/core/security.py` | JWT + password hashing |
| App config | `app/core/config.py` | Pydantic Settings from env |
| Run migrations | `app/alembic/versions/` | Alembic auto-generated |

## CONVENTIONS

- **Linter/Formatter:** Ruff (not flake8/pylint)
- **Type checker:** mypy strict mode
- **ORM:** SQLModel (not raw SQLAlchemy)
- **Migrations:** `alembic revision --autogenerate -m "desc"` after model changes
- **Package manager:** `uv` (not pip/poetry)
- **Config:** Pydantic Settings in `core/config.py`
- **Auth:** JWT via `core/security.py`, dependency `get_current_user` in `api/deps.py`
- **DB:** `get_db` generator in `api/deps.py`, SQLModel relationships

## ANTI-PATTERNS

- No `print()` in backend code (use logging)
- No raw SQLAlchemy (use SQLModel)
- No skip type annotations (mypy strict mode)
- No `uv pip` or `poetry` (use `uv`)
- No manually write migrations (use `--autogenerate`)
