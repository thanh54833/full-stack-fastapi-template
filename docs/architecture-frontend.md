# Architecture - Frontend

## Executive Summary

The frontend is a React 19 SPA with TypeScript, built with Vite, using TanStack Router for file-based routing and TanStack Query for server state management. UI components are built with shadcn/ui (Radix primitives + Tailwind CSS).

## Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Framework | React | 19.1.1 |
| Language | TypeScript | 5.9.3 |
| Build Tool | Vite | 7.3.0 |
| Router | TanStack Router | 1.163.3 |
| State Management | TanStack Query | 5.90.21 |
| Styling | Tailwind CSS | 4.2.1 |
| UI Components | shadcn/ui | Radix primitives |
| Forms | React Hook Form | 7.68.0 |
| Validation | Zod | 4.3.6 |
| Tables | TanStack Table | 8.21.3 |
| Toasts | sonner | 2.0.7 |
| Icons | Lucide React | 0.563.0 |
| Package Manager | Bun | 1.x |
| Linter | Biome | 2.3.14 |
| E2E Testing | Playwright | 1.58.2 |

## Architecture Pattern

**Component-Based Architecture** with file-based routing:

```
┌─────────────────────────────────────────────────────────┐
│                    React Entry Point                     │
│                    (main.tsx)                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │ QueryClient │  │   Router    │  │ThemeProvider │   │
│  └─────────────┘  └─────────────┘  └─────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   TanStack Router                       │
│                   (routeTree.gen.ts)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ __root → _layout → index/items/settings/admin   │   │
│  │         └─ beforeLoad: isLoggedIn() guard       │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Page Components                      │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐  │
│  │  Home   │  Items  │Settings │  Admin  │  Auth   │  │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Feature Components                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Admin/ Items/ UserSettings/ Pending/ Sidebar/  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    UI Components                        │
│                    (shadcn/ui)                          │
│  ┌──────┬──────┬──────┬──────┬──────┬──────┬──────┐   │
│  │Button│Input │Dialog│Table │Form  │Sheet │Card  │   │
│  └──────┴──────┴──────┴──────┴──────┴──────┴──────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Generated API Client                  │
│                   (client/sdk.gen.ts)                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ OpenAPI TypeScript SDK - DO NOT EDIT MANUALLY   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Backend API (FastAPI)                  │
└─────────────────────────────────────────────────────────┘
```

## State Management

### Server State (TanStack Query)

```
Component
    │
    ▼
useQuery/useMutation
    │
    ▼
Generated SDK (client/sdk.gen.ts)
    │
    ▼
Backend API
    │
    ▼
Response → Query Cache → Component Re-render
```

### Auth State

```
localStorage.access_token
    │
    ▼
useAuth() hook
    │
    ├── isLoggedIn() → Router beforeLoad guard
    ├── login() → POST /login/access-token → save token
    ├── logout() → clear token → redirect /login
    └── currentUser → GET /users/me (cached)
```

### Global Error Handling

```
Query/Mutation Error
    │
    ▼
main.tsx onError handlers
    │
    ├── 401/403 → clear token → redirect /login
    └── Other → log error
```

## Routing Architecture

### File-Based Routes

```
routes/
├── __root.tsx           # Root layout (devtools)
├── _layout.tsx          # Authenticated layout (sidebar)
├── _layout/
│   ├── index.tsx        # / (dashboard)
│   ├── items.tsx        # /items
│   ├── settings.tsx     # /settings
│   └── admin.tsx        # /admin (superuser only)
├── login.tsx            # /login
├── signup.tsx           # /signup
├── reset-password.tsx   # /reset-password
└── recover-password.tsx # /recover-password
```

### Route Guards

```typescript
// _layout.tsx
beforeLoad: async ({ context }) => {
  if (!isLoggedIn()) {
    throw redirect({ to: '/login' })
  }
}
```

## Component Organization

```
components/
├── ui/                  # shadcn/ui primitives (DO NOT EDIT)
│   ├── button.tsx
│   ├── input.tsx
│   ├── dialog.tsx
│   └── ...
├── Common/              # Shared components
│   ├── DataTable.tsx    # Reusable table with TanStack Table
│   ├── ErrorComponent.tsx
│   ├── NotFound.tsx
│   └── ...
├── Admin/               # Admin panel components
├── Items/               # Items feature components
├── UserSettings/        # User settings components
├── Pending/             # Pending approval components
└── Sidebar/             # Navigation sidebar
```

## Styling Architecture

### Tailwind CSS v4 with CSS Variables

```css
/* index.css */
@import "tailwindcss";
@import "tw-animate-css";

@theme inline {
  --color-background: oklch(0.145 0 0);
  --color-foreground: oklch(0.985 0 0);
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  /* ... */
}
```

### Dark Mode

- Default: Dark theme
- Toggle: `next-themes` with `ThemeProvider`
- CSS: `.dark` class with OKLCH color variables

### Class Merging

```typescript
// lib/utils.ts
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

## Source Tree

```
frontend/
├── src/
│   ├── main.tsx              # Entry point
│   ├── routeTree.gen.ts      # Auto-generated routes (DO NOT EDIT)
│   ├── index.css             # Tailwind + theme variables
│   ├── lib/
│   │   └── utils.ts          # cn() utility
│   ├── components/
│   │   ├── ui/               # shadcn/ui (DO NOT EDIT)
│   │   ├── Common/           # Shared components
│   │   ├── Admin/            # Admin features
│   │   ├── Items/            # Items features
│   │   ├── UserSettings/     # User settings
│   │   ├── Pending/          # Pending approvals
│   │   └── Sidebar/          # Navigation
│   ├── routes/               # TanStack file-based routes
│   ├── hooks/                # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useCustomToast.ts
│   │   ├── useMobile.ts
│   │   └── useCopyToClipboard.ts
│   └── client/               # Auto-generated API client (DO NOT EDIT)
├── tests/                    # Playwright E2E tests
├── package.json
├── biome.json
└── vite.config.ts
```

## Development Workflow

1. **Add Page:** Create file in `routes/` → Auto-generates route
2. **Add Component:** Create in `components/[Feature]/`
3. **Add Hook:** Create in `hooks/` with `use` prefix
4. **Add UI Component:** `npx shadcn@latest add [component]`
5. **Update API Client:** Run `bash ../scripts/generate-client.sh`

## Testing Strategy

- **E2E Tests:** Playwright in `tests/`
- **Element Selection:** `data-testid` attributes
- **Parallel Execution:** 4 shards in CI
- **Test Config:** `tests/config.ts` with env vars

## Links

- [Component Inventory](./component-inventory-frontend.md)
- [Development Guide](./development-guide-frontend.md)
- [Integration Architecture](./integration-architecture.md)
