# Architecture - Backend

## Executive Summary

The backend is a Python/FastAPI REST API with SQLModel ORM, PostgreSQL database, and JWT authentication. It follows a layered architecture pattern with clear separation between routes, business logic (CRUD), and data models.

## Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Framework | FastAPI | 0.114.2+ |
| Language | Python | 3.10 |
| ORM | SQLModel | 0.0.21+ |
| Database | PostgreSQL | 18 |
| Migrations | Alembic | 1.12.1+ |
| Auth | JWT (PyJWT) | 2.8.0+ |
| Password Hashing | pwdlib (Argon2 + Bcrypt) | 0.3.0+ |
| Package Manager | uv | 0.9.26 |
| Linter | Ruff | 0.2.2+ |
| Type Checker | MyPy | 1.8.0+ (strict) |

## Architecture Pattern

**Layered Architecture** with dependency injection:

```
┌─────────────────────────────────────────────────────────┐
│                    FastAPI Application                   │
│                    (backend/app/main.py)                 │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      API Router                         │
│                  (api/main.py)                          │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐  │
│  │  login  │  users  │  items  │  utils  │ private │  │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Dependencies                          │
│                   (api/deps.py)                         │
│  ┌──────────────┐  ┌────────────────────────────────┐  │
│  │   get_db()   │  │  get_current_user()            │  │
│  │              │  │  get_current_active_superuser() │  │
│  └──────────────┘  └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    CRUD Layer                           │
│                    (crud.py)                            │
│  ┌──────────────┐  ┌────────────────────────────────┐  │
│  │ User CRUD    │  │ Item CRUD                      │  │
│  │ create/update│  │ create/read/update/delete      │  │
│  │ authenticate │  │                                │  │
│  └──────────────┘  └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Data Models                           │
│                   (models.py)                          │
│  ┌──────────────┐  ┌────────────────────────────────┐  │
│  │    User      │  │      Item                      │  │
│  │  (SQLModel)  │──│  (SQLModel, FK to User)        │  │
│  └──────────────┘  └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  PostgreSQL Database                     │
└─────────────────────────────────────────────────────────┘
```

## Data Architecture

### Database Schema

**User Table:**
- `id`: UUID (PK)
- `email`: String (unique, indexed)
- `is_active`: Boolean (default: true)
- `is_superuser`: Boolean (default: false)
- `full_name`: String (nullable)
- `hashed_password`: String
- `created_at`: DateTime (with timezone)

**Item Table:**
- `id`: UUID (PK)
- `title`: String (max 255)
- `description`: String (nullable, max 255)
- `owner_id`: UUID (FK to User.id, cascade delete)
- `created_at`: DateTime (with timezone)

### Relationships

```
User 1 ──── * Item
(owner_id FK with CASCADE DELETE)
```

## API Design

### Authentication Flow

```
1. POST /api/v1/login/access-token
   Body: { username: email, password: password }
   Response: { access_token: JWT, token_type: "bearer" }

2. Subsequent requests:
   Header: Authorization: Bearer <JWT_TOKEN>

3. Token validation via get_current_user() dependency
```

### Endpoint Categories

| Category | Endpoints | Auth Required | Superuser Only |
|----------|-----------|---------------|----------------|
| Login | 4 | No (except test-token) | No |
| Users | 10 | Yes (except signup) | Some |
| Items | 5 | Yes | No |
| Utils | 2 | Yes | test-email only |
| Private | 1 | No (local only) | No |

## Security Architecture

### Password Handling

```
User Password
    │
    ▼
┌─────────────────┐
│ pwdlib          │
│ ┌─────────────┐ │
│ │ Argon2      │ │ ← Primary hasher
│ │ (preferred) │ │
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ Bcrypt      │ │ ← Fallback
│ │ (fallback)  │ │
│ └─────────────┘ │
└─────────────────┘
    │
    ▼
hashed_password (stored in DB)
```

### JWT Token Flow

```
Login Request
    │
    ▼
┌─────────────────┐
│ authenticate()  │
│ - timing-safe   │
│ - hash upgrade  │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ create_token()  │
│ - HS256         │
│ - 8 day expiry  │
│ - sub=user_id   │
└─────────────────┘
    │
    ▼
JWT Access Token
```

## Source Tree

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── login.py      # Auth endpoints
│   │   │   ├── users.py      # User CRUD
│   │   │   ├── items.py      # Item CRUD
│   │   │   ├── utils.py      # Health check, test email
│   │   │   └── private.py    # Local-only endpoints
│   │   ├── deps.py           # Dependency injection
│   │   └── main.py           # API router aggregation
│   ├── core/
│   │   ├── config.py         # Pydantic Settings
│   │   ├── security.py       # JWT + password hashing
│   │   └── db.py             # Database engine
│   ├── alembic/              # Database migrations
│   ├── email-templates/      # MJML email templates
│   ├── main.py               # FastAPI app entry
│   ├── models.py             # SQLModel definitions
│   ├── crud.py               # Database operations
│   ├── utils.py              # Email utilities
│   └── initial_data.py       # First superuser creation
├── tests/                    # Pytest suite
├── scripts/                  # Build/test scripts
└── pyproject.toml            # Dependencies + config
```

## Development Workflow

1. **Add Model:** Edit `models.py` → `alembic revision --autogenerate`
2. **Add CRUD:** Edit `crud.py`
3. **Add Route:** Create in `api/routes/` → Register in `api/main.py`
4. **Add Dependency:** Edit `api/deps.py`
5. **Change Config:** Edit `core/config.py`

## Testing Strategy

- **Unit Tests:** CRUD operations in `tests/crud/`
- **API Tests:** Route handlers in `tests/api/routes/`
- **Integration Tests:** Full request/response cycles
- **Coverage:** 90% minimum enforced by CI

## Links

- [API Contracts](./api-contracts-backend.md)
- [Data Models](./data-models-backend.md)
- [Development Guide](./development-guide-backend.md)
