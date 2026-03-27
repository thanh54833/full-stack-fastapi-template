# Frontend Knowledge Base

**Generated:** 2026-03-27

## OVERVIEW

React + TypeScript frontend with Vite, TanStack Router/Query, Tailwind CSS, shadcn/ui

## STRUCTURE

```
frontend/src/
├── main.tsx              # React entry point
├── routeTree.gen.ts      # Auto-generated TanStack routes
├── App.tsx               # Root app with routing
├── components/
│   ├── ui/               # shadcn/ui components (Button, Input, etc.)
│   ├── Admin/            # Admin-specific components
│   ├── Common/           # Shared components
│   ├── Items/            # Items feature components
│   ├── Sidebar/          # Sidebar navigation
│   └── UserSettings/     # User settings components
├── routes/               # TanStack file-based routing
│   ├── __root.tsx        # Root route
│   ├── index.tsx         # Home page
│   └── ...
├── hooks/                # Custom React hooks
│   ├── useAuth.ts        # Authentication state
│   ├── useCustomToast.ts # Toast notifications
│   ├── useMobile.ts      # Mobile detection
│   └── useCopyToClipboard.ts
├── client/               # Auto-generated OpenAPI client (DO NOT EDIT)
└── lib/                  # Utilities
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add page/route | `src/routes/` | TanStack file-based, auto-generates routeTree |
| Add component | `src/components/` | Organize by feature subdirectory |
| Add custom hook | `src/hooks/` | Prefix with `use` |
| UI component | `src/components/ui/` | shadcn/ui, add via CLI |
| E2E test | `tests/` | Playwright spec files |
| Styling config | `tailwind.config.ts` | Tailwind theme |
| App config | `vite.config.ts` | Vite configuration |

## CONVENTIONS

- **Linter/Formatter:** Biome (run `bun run lint`)
- **Routing:** TanStack Router file-based routing, routes auto-generated to `routeTree.gen.ts`
- **Data fetching:** TanStack Query (useQuery/useMutation hooks)
- **Components:** shadcn/ui, import from `@/components/ui/`
- **Styling:** Tailwind CSS classes, use cn() utility for conditional classes
- **Testing:** Playwright with `data-testid` attributes for element selection
- **API calls:** Use generated client in `src/client/`, never call fetch directly

## ANTI-PATTERNS

- **NEVER edit `src/client/`** - Auto-generated from OpenAPI, run `bash ../scripts/generate-client.sh` after backend changes
- **NEVER use `as any` or `@ts-ignore`** - Type safety is required
- **NEVER skip `data-testid`** - Required for Playwright E2E tests
- **NEVER use ESLint/Prettier** - Use Biome instead
- **NEVER use npm/yarn** - Use Bun
- **NEVER use fetch/axios directly** - Use generated client methods
- **NEVER use CSS modules/styled-components** - Use Tailwind CSS

## KEY COMMANDS

```bash
bun run dev              # Start dev server
bun run lint             # Lint with Biome
bunx playwright test     # Run E2E tests
bash ../scripts/generate-client.sh  # Regenerate API client
```
