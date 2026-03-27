# Development Guide - Backend

## Prerequisites

- **Python:** 3.10+
- **Package Manager:** uv (recommended) or pip
- **Database:** PostgreSQL 18 (via Docker)
- **Docker:** For full stack development

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# From project root
docker compose watch
```

This starts all services with live reload:
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Database: localhost:5432

### Option 2: Local Development

```bash
cd backend

# Install dependencies
uv sync

# Activate virtual environment
source .venv/bin/activate

# Start PostgreSQL (via Docker)
docker compose up -d db

# Run migrations
alembic upgrade head

# Create first superuser (if needed)
python -m app.initial_data

# Start dev server
fastapi dev app/main.py
```

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/         # API endpoints
│   │   ├── deps.py         # Dependencies (get_db, get_current_user)
│   │   └── main.py         # Router aggregation
│   ├── core/
│   │   ├── config.py       # Settings (Pydantic)
│   │   ├── security.py     # JWT + password hashing
│   │   └── db.py           # Database engine
│   ├── alembic/            # Migrations
│   ├── models.py           # SQLModel definitions
│   ├── crud.py             # Database operations
│   ├── utils.py            # Email utilities
│   └── main.py             # FastAPI app entry
├── tests/                  # Pytest suite
├── scripts/                # Build/test scripts
└── pyproject.toml          # Dependencies + config
```

## Common Tasks

### Add New API Endpoint

1. **Create route file:**
```python
# app/api/routes/new_feature.py
from fastapi import APIRouter, Depends
from sqlmodel import Session
from app.api.deps import get_db, get_current_user

router = APIRouter()

@router.get("/")
def read_items(db: Session = Depends(get_db)):
    # Implementation
    pass
```

2. **Register in api/main.py:**
```python
from app.api.routes import new_feature

api_router.include_router(new_feature.router, prefix="/new-feature", tags=["new-feature"])
```

### Add New Database Model

1. **Define in models.py:**
```python
from sqlmodel import SQLModel, Field
import uuid
from datetime import datetime, timezone

class NewModel(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str = Field(max_length=255)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
```

2. **Create migration:**
```bash
alembic revision --autogenerate -m "Add new_model table"
alembic upgrade head
```

3. **Add CRUD operations in crud.py**

### Add New CRUD Operation

```python
# app/crud.py
def create_new_model(db: Session, obj_in: NewModelCreate) -> NewModel:
    db_obj = NewModel.model_validate(obj_in)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj
```

### Modify Configuration

```python
# app/core/config.py
class Settings(BaseSettings):
    # Add new setting
    MY_NEW_SETTING: str = "default_value"
```

Then use: `settings.MY_NEW_SETTING`

## Testing

### Run All Tests

```bash
cd backend
bash ./scripts/test.sh
```

### Run Specific Test

```bash
pytest tests/api/routes/test_users.py -v
```

### Run with Coverage

```bash
pytest --cov=app --cov-report=html
```

### Test Structure

```
tests/
├── api/routes/             # API endpoint tests
│   ├── test_login.py
│   ├── test_users.py
│   ├── test_items.py
│   └── test_private.py
├── crud/                   # CRUD operation tests
│   └── test_user.py
├── scripts/                # Pre-start tests
├── conftest.py             # Fixtures (db, client, tokens)
└── utils/                  # Test helpers
```

### Writing Tests

```python
# tests/api/routes/test_new_feature.py
from fastapi.testclient import TestClient
from sqlmodel import Session

def test_read_items(client: TestClient, superuser_token_headers: dict):
    response = client.get("/api/v1/items/", headers=superuser_token_headers)
    assert response.status_code == 200
    data = response.json()
    assert "data" in data
```

## Linting & Formatting

### Ruff (Linter + Formatter)

```bash
# Check for issues
ruff check .

# Auto-fix issues
ruff check --fix .

# Format code
ruff format .
```

### MyPy (Type Checker)

```bash
mypy app
```

### Pre-commit

```bash
# Run all hooks
prek run --all-files

# Run specific hook
prek run ruff --all-files
```

## Database Migrations

### Create Migration

```bash
# After modifying models.py
alembic revision --autogenerate -m "Description of changes"
```

### Apply Migrations

```bash
alembic upgrade head
```

### Rollback Migration

```bash
alembic downgrade -1
```

### View Migration History

```bash
alembic history
```

## Email Templates

### Location

```
app/email-templates/
├── src/                    # MJML source files
│   ├── new_account.mjml
│   ├── reset_password.mjml
│   └── test_email.mjml
└── build/                  # Compiled HTML
    ├── new_account.html
    ├── reset_password.html
    └── test_email.html
```

### Edit Templates

1. Install MJML VS Code extension
2. Edit `.mjml` file in `src/`
3. Run "MJML: Export to HTML" (Ctrl+Shift+P)
4. Save to `build/` directory

## Environment Variables

Key variables in `.env`:

```bash
# Database
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_DB=app
POSTGRES_USER=postgres
POSTGRES_PASSWORD=changethis

# Security
SECRET_KEY=changethis
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=changethis

# CORS
BACKEND_CORS_ORIGINS="http://localhost,http://localhost:5173"

# Email (optional)
SMTP_HOST=
SMTP_USER=
SMTP_PASSWORD=
EMAILS_FROM_EMAIL=info@example.com
```

## Debugging

### VS Code

Launch configurations in `.vscode/launch.json`:
- **Python: FastAPI** - Start backend with debugger
- **Python: Debug Tests** - Run tests with breakpoints

### Print Debugging

```python
import logging
logger = logging.getLogger(__name__)

logger.debug("Debug message")
logger.info("Info message")
logger.error("Error message")
```

**Note:** Don't use `print()` in production code (Ruff will flag it).

## Common Issues

### Import Errors

```bash
# Ensure virtual environment is activated
source .venv/bin/activate

# Reinstall dependencies
uv sync
```

### Database Connection Errors

```bash
# Check PostgreSQL is running
docker compose ps

# Restart database
docker compose restart db
```

### Migration Conflicts

```bash
# View current revision
alembic current

# Stamp database with revision (if out of sync)
alembic stamp head
```

## Links

- [Architecture - Backend](./architecture-backend.md)
- [API Contracts](./api-contracts-backend.md)
- [Data Models](./data-models-backend.md)
