# Source Tree Analysis

## Project Root

```
full-stack-fastapi-template/
├── _bmad/                          # BMAD installation (AI agent framework)
├── _bmad-output/                   # BMAD generated artifacts
├── .copier/                        # Copier template configuration
├── .github/                        # GitHub Actions workflows (12 workflows)
├── .opencode/                      # OpenCode configuration
├── .sisyphus/                      # Sisyphus AI agent config
├── .vscode/                        # VS Code settings
├── backend/                        # Python FastAPI backend
├── frontend/                       # React TypeScript frontend
├── docs/                           # Project documentation (this)
├── hooks/                          # Git hooks
├── img/                            # README images
├── scripts/                        # Project-level automation
├── .env                            # Environment variables (root)
├── .pre-commit-config.yaml         # Pre-commit hooks config
├── compose.yml                     # Docker Compose (production)
├── compose.override.yml            # Docker Compose (development)
├── compose.traefik.yml             # Traefik production config
├── copier.yml                      # Copier template variables
├── makefile                        # Make commands
├── package.json                    # Root workspace (bun)
├── pyproject.toml                  # Root workspace (uv)
├── uv.lock                         # Python dependency lock
├── bun.lock                        # JavaScript dependency lock
├── AGENTS.md                       # AI agent knowledge base
├── CLAUDE.md                       # Claude Code CLI guidance
├── CONTRIBUTING.md                 # Contribution guidelines
├── README.md                       # Main documentation
├── SECURITY.md                     # Security policy
├── deployment.md                   # Deployment guide
├── development.md                  # Development guide
└── release-notes.md                # Version history
```

## Backend Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── login.py            # POST /login/access-token
│   │   │   │                       # POST /login/test-token
│   │   │   │                       # POST /password-recovery/{email}
│   │   │   │                       # POST /reset-password/
│   │   │   ├── users.py            # GET/POST/PATCH/DELETE /users
│   │   │   │                       # GET/PATCH/DELETE /users/me
│   │   │   │                       # POST /signup
│   │   │   ├── items.py            # CRUD /items
│   │   │   ├── utils.py            # /utils/test-email, /utils/health-check
│   │   │   └── private.py          # /private/users (local only)
│   │   ├── deps.py                 # get_db, get_current_user, get_current_active_superuser
│   │   └── main.py                 # api_router aggregation
│   ├── core/
│   │   ├── config.py               # Settings (Pydantic)
│   │   ├── security.py             # JWT + pwdlib (Argon2/Bcrypt)
│   │   └── db.py                   # SQLAlchemy engine
│   ├── alembic/
│   │   ├── versions/               # Migration files (5 migrations)
│   │   ├── env.py                  # Alembic environment
│   │   └── script.py.mako          # Migration template
│   ├── email-templates/
│   │   ├── src/                    # MJML source files
│   │   └── build/                  # Compiled HTML templates
│   ├── main.py                     # FastAPI app entry point
│   ├── models.py                   # SQLModel definitions (User, Item)
│   ├── crud.py                     # Database operations
│   ├── utils.py                    # Email utilities
│   └── initial_data.py             # First superuser creation
├── tests/
│   ├── api/routes/                 # API endpoint tests
│   ├── crud/                       # CRUD operation tests
│   ├── scripts/                    # Pre-start tests
│   ├── conftest.py                 # Pytest fixtures
│   └── utils/                      # Test utilities
├── scripts/
│   ├── format.sh                   # Ruff formatting
│   ├── lint.sh                     # Ruff + MyPy linting
│   ├── test.sh                     # Pytest runner
│   ├── tests-start.sh              # Test with DB
│   └── prestart.sh                 # Pre-deployment
├── Dockerfile                      # Python 3.10 + uv
├── pyproject.toml                  # Dependencies + Ruff/MyPy config
└── README.md                       # Backend documentation
```

### Critical Backend Folders

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| `app/api/routes/` | API endpoints | login.py, users.py, items.py |
| `app/core/` | Configuration | config.py, security.py, db.py |
| `app/alembic/versions/` | Migrations | 5 migration files |
| `tests/` | Test suite | conftest.py, api/, crud/ |

## Frontend Structure

```
frontend/
├── src/
│   ├── main.tsx                    # React entry point
│   ├── routeTree.gen.ts            # Auto-generated routes (DO NOT EDIT)
│   ├── index.css                   # Tailwind CSS + theme variables
│   ├── lib/
│   │   └── utils.ts                # cn() utility
│   ├── components/
│   │   ├── ui/                     # shadcn/ui primitives (25+ components)
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── table.tsx
│   │   │   ├── form.tsx
│   │   │   └── ...
│   │   ├── Common/                 # Shared components
│   │   │   ├── DataTable.tsx
│   │   │   ├── ErrorComponent.tsx
│   │   │   ├── NotFound.tsx
│   │   │   ├── Logo.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── AuthLayout.tsx
│   │   ├── Admin/                  # Admin panel
│   │   │   ├── AddUser.tsx
│   │   │   ├── EditUser.tsx
│   │   │   ├── DeleteUser.tsx
│   │   │   ├── UserActionsMenu.tsx
│   │   │   └── columns.tsx
│   │   ├── Items/                  # Items management
│   │   │   ├── AddItem.tsx
│   │   │   ├── EditItem.tsx
│   │   │   ├── DeleteItem.tsx
│   │   │   ├── ItemActionsMenu.tsx
│   │   │   └── columns.tsx
│   │   ├── UserSettings/           # User settings
│   │   │   ├── UserInformation.tsx
│   │   │   ├── ChangePassword.tsx
│   │   │   ├── DeleteAccount.tsx
│   │   │   └── DeleteConfirmation.tsx
│   │   ├── Pending/                # Pending approvals
│   │   │   ├── PendingUsers.tsx
│   │   │   └── PendingItems.tsx
│   │   └── Sidebar/                # Navigation
│   │       ├── AppSidebar.tsx
│   │       ├── User.tsx
│   │       └── Main.tsx
│   ├── routes/                     # TanStack file-based routes
│   │   ├── __root.tsx              # Root layout
│   │   ├── _layout.tsx             # Authenticated layout
│   │   ├── _layout/
│   │   │   ├── index.tsx           # Dashboard
│   │   │   ├── items.tsx           # Items page
│   │   │   ├── settings.tsx        # Settings page
│   │   │   └── admin.tsx           # Admin page
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   ├── reset-password.tsx
│   │   └── recover-password.tsx
│   ├── hooks/                      # Custom React hooks
│   │   ├── useAuth.ts              # Auth state management
│   │   ├── useCustomToast.ts       # Toast notifications
│   │   ├── useMobile.ts            # Mobile detection
│   │   └── useCopyToClipboard.ts   # Clipboard utility
│   └── client/                     # Auto-generated API client (DO NOT EDIT)
│       ├── index.ts
│       ├── sdk.gen.ts
│       ├── types.gen.ts
│       ├── schemas.gen.ts
│       └── core/
├── tests/                          # Playwright E2E tests
│   ├── login.spec.ts
│   ├── sign-up.spec.ts
│   ├── reset-password.spec.ts
│   ├── items.spec.ts
│   ├── admin.spec.ts
│   ├── user-settings.spec.ts
│   ├── config.ts
│   ├── auth.setup.ts
│   └── utils/
├── package.json
├── biome.json                      # Biome linter config
├── vite.config.ts                  # Vite build config
├── tsconfig.json                   # TypeScript config
└── README.md                       # Frontend documentation
```

### Critical Frontend Folders

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| `src/routes/` | Page routing | _layout.tsx, index.tsx, items.tsx |
| `src/components/ui/` | UI primitives | 25+ shadcn/ui components |
| `src/components/` | Feature components | Admin/, Items/, UserSettings/ |
| `src/hooks/` | Custom hooks | useAuth.ts |
| `src/client/` | API client | sdk.gen.ts (auto-generated) |
| `tests/` | E2E tests | 6 spec files |

## Entry Points

| Component | Entry Point | Command |
|-----------|-------------|---------|
| Backend | `backend/app/main.py` | `fastapi dev app/main.py` |
| Frontend | `frontend/src/main.tsx` | `bun run dev` |
| Docker | `compose.yml` | `docker compose watch` |

## Integration Points

```
Frontend (React)                    Backend (FastAPI)
      │                                    │
      │  src/client/sdk.gen.ts             │
      │  (auto-generated from OpenAPI)     │
      │                                    │
      ├──── POST /api/v1/login/access-token ────►│
      │◄─── { access_token: JWT } ──────────────┤
      │                                    │
      ├──── GET /api/v1/users/me ──────────►│
      │     Authorization: Bearer <JWT>    │
      │◄─── { user data } ─────────────────┤
      │                                    │
      ├──── GET /api/v1/items/ ────────────►│
      │◄─── { items: [...] } ──────────────┤
      │                                    │
```

## Links

- [Architecture - Backend](./architecture-backend.md)
- [Architecture - Frontend](./architecture-frontend.md)
- [Integration Architecture](./integration-architecture.md)
