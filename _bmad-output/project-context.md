---
project_name: 'full-stack-fastapi-template'
user_name: 'Phamthanh'
date: '2026-03-27'
sections_completed: ['technology_stack', 'critical_rules', 'patterns', 'conventions']
existing_patterns_found: 47
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

### Backend
| Technology | Version | Notes |
|------------|---------|-------|
| Python | 3.10 | `>=3.10,<4.0` |
| FastAPI | 0.114.2+ | With `[standard]` extras |
| SQLModel | 0.0.21+ | ORM (SQLAlchemy + Pydantic) |
| PostgreSQL | 18 | Primary database |
| Alembic | 1.12.1+ | Migrations |
| PyJWT | 2.8.0+ | JWT authentication |
| pwdlib | 0.3.0+ | Password hashing (Argon2 + Bcrypt) |
| uv | 0.9.26 | Package manager (NOT pip/poetry) |
| Ruff | 0.2.2+ | Linter + formatter |
| MyPy | 1.8.0+ | Type checker (strict mode) |

### Frontend
| Technology | Version | Notes |
|------------|---------|-------|
| React | 19.1.1 | UI library |
| TypeScript | 5.9.3 | Language |
| Vite | 7.3.0 | Build tool |
| TanStack Router | 1.163.3 | File-based routing |
| TanStack Query | 5.90.21 | Server state management |
| Tailwind CSS | 4.2.1 | Styling (v4 with CSS variables) |
| shadcn/ui | Radix primitives | UI components |
| Biome | 2.3.14 | Linter + formatter |
| Playwright | 1.58.2 | E2E testing |
| Bun | 1.x | Package manager (NOT npm/yarn) |

### Infrastructure
| Technology | Version | Notes |
|------------|---------|-------|
| Docker Compose | - | Orchestration |
| Traefik | 3.6 | Reverse proxy |
| GitHub Actions | - | CI/CD (12 workflows) |

---

## Critical Implementation Rules

### Backend Rules (Python/FastAPI)

1. **NEVER use `print()`** — Use `logging` module instead. Ruff will flag `T201`.

2. **NEVER skip type annotations** — MyPy strict mode is enabled. Every function must have typed parameters and return values.

3. **NEVER use raw SQLAlchemy** — Use SQLModel exclusively. SQLModel combines SQLAlchemy + Pydantic.

4. **NEVER manually write migrations** — Always use `alembic revision --autogenerate -m "desc"`.

5. **NEVER use pip/poetry** — Use `uv` for all package management:
   ```bash
   uv sync                    # Install dependencies
   uv add <package>           # Add dependency
   uv add --dev <package>     # Add dev dependency
   ```

6. **ALWAYS use Pydantic v2 syntax:**
   - `model_validate()` instead of `parse_obj()`
   - `model_dump()` instead of `dict()`
   - `model_dump_json()` instead of `json()`
   - `sqlmodel_update()` for partial updates

7. **UUID primary keys** — All models use `uuid.UUID` with `default_factory=uuid.uuid4`.

8. **Datetime with timezone** — Always use `datetime.now(timezone.utc)`.

9. **Password hashing** — Use `pwdlib` with Argon2 (primary) + Bcrypt (fallback).

10. **JWT tokens** — 8-day expiry, HS256 algorithm, `sub` claim = user ID.

### Frontend Rules (React/TypeScript)

1. **NEVER edit `src/client/`** — Auto-generated from OpenAPI. Run `bash ../scripts/generate-client.sh` after backend changes.

2. **NEVER use `as any` or `@ts-ignore`** — Type safety is required.

3. **NEVER use ESLint/Prettier** — Use Biome exclusively:
   ```bash
   bun run lint               # Check issues
   bun run lint --write       # Auto-fix
   ```

4. **NEVER use npm/yarn** — Use Bun:
   ```bash
   bun install                # Install dependencies
   bun add <package>          # Add dependency
   bun run dev                # Start dev server
   ```

5. **NEVER use fetch/axios directly** — Use generated client methods from `@/client`.

6. **NEVER use CSS modules/styled-components** — Use Tailwind CSS with `cn()` utility.

7. **ALWAYS use `data-testid`** — Required for Playwright E2E tests.

8. **ALWAYS use TanStack Query** — For all server state:
   ```typescript
   useQuery({ queryKey: ["items"], queryFn: () => ItemsService.readItems() })
   useMutation({ mutationFn: (data) => ItemsService.createItem({ requestBody: data }) })
   ```

9. **ALWAYS use file-based routing** — Create files in `src/routes/`, auto-generates to `routeTree.gen.ts`.

10. **ALWAYS use shadcn/ui** — Import from `@/components/ui/`. Add new components via CLI:
    ```bash
    npx shadcn@latest add dialog
    ```

---

## Code Patterns

### Backend Patterns

#### API Route Pattern
```python
# app/api/routes/items.py
from fastapi import APIRouter, Depends
from sqlmodel import Session
from app.api.deps import get_db, get_current_user
from app.models import Item, ItemCreate, ItemPublic, ItemsPublic
from app.crud import create_item

router = APIRouter()

@router.get("/", response_model=ItemsPublic)
def read_items(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
) -> Any:
    # Implementation
    pass
```

#### CRUD Pattern
```python
# app/crud.py
def create_item(db: Session, item_in: ItemCreate, owner_id: uuid.UUID) -> Item:
    db_obj = Item.model_validate(item_in, update={"owner_id": owner_id})
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj
```

#### Dependency Injection Pattern
```python
# app/api/deps.py
def get_current_user(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)) -> User:
    # Validate JWT, fetch user from DB
    pass
```

### Frontend Patterns

#### Page Component Pattern
```tsx
// src/routes/_layout/items.tsx
import { createFileRoute } from "@tanstack/react-router"
import { useQuery } from "@tanstack/react-query"
import { ItemsService } from "@/client"

export const Route = createFileRoute("/_layout/items")({
  component: ItemsPage,
})

function ItemsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["items"],
    queryFn: () => ItemsService.readItems({ skip: 0, limit: 100 }),
  })

  if (isLoading) return <div>Loading...</div>

  return <DataTable columns={columns} data={data?.data ?? []} />
}
```

#### Form Pattern
```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"

const schema = z.object({ title: z.string().min(1).max(255) })

function AddItem() {
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
  })

  const mutation = useMutation({
    mutationFn: (data) => ItemsService.createItem({ requestBody: data }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["items"] }),
  })

  return <Form {...form}>...</Form>
}
```

---

## File Naming Conventions

### Backend
| Type | Convention | Example |
|------|-----------|---------|
| Route files | `snake_case.py` | `user_items.py` |
| Model files | `snake_case.py` | `models.py` |
| Test files | `test_*.py` | `test_users.py` |

### Frontend
| Type | Convention | Example |
|------|-----------|---------|
| Components | `PascalCase.tsx` | `AddItem.tsx` |
| Hooks | `use*.ts` | `useAuth.ts` |
| Routes | `kebab-case.tsx` | `user-settings.tsx` |
| Utilities | `camelCase.ts` | `formatDate.ts` |
| Tests | `*.spec.ts` | `login.spec.ts` |

---

## Anti-Patterns (NEVER DO)

### Backend
- ❌ `print()` statements
- ❌ Raw SQLAlchemy (use SQLModel)
- ❌ Manual migrations (use `--autogenerate`)
- ❌ pip/poetry (use uv)
- ❌ Untyped functions
- ❌ `from __future__ import annotations` (breaks SQLModel)

### Frontend
- ❌ Editing `src/client/` directly
- ❌ `as any` or `@ts-ignore`
- ❌ ESLint/Prettier (use Biome)
- ❌ npm/yarn (use Bun)
- ❌ Direct fetch/axios calls
- ❌ CSS modules/styled-components
- ❌ Missing `data-testid` on interactive elements

---

## Development Commands

### Backend
```bash
cd backend
uv sync                                    # Install dependencies
source .venv/bin/activate                  # Activate venv
fastapi dev app/main.py                    # Start dev server
bash ./scripts/test.sh                     # Run tests
alembic revision --autogenerate -m "desc"  # Create migration
alembic upgrade head                       # Apply migrations
ruff check --fix .                         # Lint + fix
mypy app                                   # Type check
```

### Frontend
```bash
cd frontend
bun install                                # Install dependencies
bun run dev                                # Start dev server
bun run lint                               # Lint with Biome
bunx playwright test                       # Run E2E tests
bash ../scripts/generate-client.sh         # Regenerate API client
```

### Docker
```bash
docker compose watch                        # Start all services (dev)
docker compose -f compose.yml up -d         # Start all services (prod)
docker compose logs -f backend              # View backend logs
docker compose exec backend bash            # Shell into backend
```

---

## Key Files Reference

| Task | Backend File | Frontend File |
|------|-------------|---------------|
| Add API endpoint | `app/api/routes/*.py` | Auto-generated in `src/client/` |
| Add DB model | `app/models.py` | N/A |
| Add CRUD | `app/crud.py` | N/A |
| Add page | N/A | `src/routes/*.tsx` |
| Add component | N/A | `src/components/**/*.tsx` |
| Add hook | N/A | `src/hooks/use*.ts` |
| Change config | `app/core/config.py` | `vite.config.ts` |
| Change auth | `app/core/security.py` | `src/hooks/useAuth.ts` |
| Add migration | `app/alembic/versions/` | N/A |
| Add E2E test | N/A | `tests/*.spec.ts` |

---

## Environment Variables

### Required (.env)
```bash
SECRET_KEY=<generate-with-secrets.token_urlsafe(32)>
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=<strong-password>
POSTGRES_PASSWORD=<strong-password>
```

### Optional
```bash
SMTP_HOST=smtp.example.com
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-smtp-password
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

---

_Last updated: 2026-03-27 by BMAD project discovery scan_
